package com.example.dacs3

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel

class BankNotificationListenerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val notification = sbn?.notification ?: return
        val extras = notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString().orEmpty()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString().orEmpty()
        val body = listOf(title, text, bigText, subText)
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .distinct()
            .joinToString(". ")

        if (body.isBlank()) {
            return
        }

        BankNotificationStream.emit(
            mapOf(
                "sender" to sbn.packageName,
                "body" to body,
                "timestampMs" to sbn.postTime
            )
        )
    }
}

object BankNotificationStream : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val pendingEvents = ArrayDeque<Map<String, Any?>>()

    fun emit(event: Map<String, Any?>) {
        val activeSink = sink
        if (activeSink == null) {
            if (pendingEvents.size >= 20) {
                pendingEvents.removeFirst()
            }
            pendingEvents.addLast(event)
            return
        }
        activeSink.success(event)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        while (pendingEvents.isNotEmpty()) {
            sink?.success(pendingEvents.removeFirst())
        }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}
