package com.example.dacs3

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val bankMessagesChannel = "dacs3/bank_messages"
    private val bankNotificationsChannel = "dacs3/bank_notifications"
    private val readSmsRequestCode = 4102
    private var pendingSmsResult: MethodChannel.Result? = null
    private var pendingSmsLimit: Int = 50

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bankMessagesChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readRecentSms" -> {
                        pendingSmsLimit = call.argument<Int>("limit") ?: 50
                        readRecentSms(result)
                    }
                    "isNotificationAccessEnabled" -> {
                        result.success(isNotificationAccessEnabled())
                    }
                    "openNotificationAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, bankNotificationsChannel)
            .setStreamHandler(BankNotificationStream)
    }

    private fun isNotificationAccessEnabled(): Boolean {
        val enabledListeners = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false
        return enabledListeners.split(":").any { item ->
            item.contains(packageName, ignoreCase = true)
        }
    }

    private fun readRecentSms(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            pendingSmsResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_SMS),
                readSmsRequestCode
            )
            return
        }

        result.success(querySms(pendingSmsLimit))
    }

    private fun querySms(limit: Int): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf(
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE
        )
        val sortOrder = "${Telephony.Sms.DATE} DESC"

        contentResolver.query(uri, projection, null, null, sortOrder)?.use { cursor ->
            val senderIndex = cursor.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = cursor.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = cursor.getColumnIndex(Telephony.Sms.DATE)
            while (cursor.moveToNext() && messages.size < limit) {
                messages.add(
                    mapOf(
                        "sender" to cursor.getString(senderIndex),
                        "body" to cursor.getString(bodyIndex),
                        "timestampMs" to cursor.getLong(dateIndex)
                    )
                )
            }
        }
        return messages
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != readSmsRequestCode) {
            return
        }

        val result = pendingSmsResult ?: return
        pendingSmsResult = null
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            result.success(querySms(pendingSmsLimit))
        } else {
            result.error("sms_permission_denied", "READ_SMS permission was denied.", null)
        }
    }
}
