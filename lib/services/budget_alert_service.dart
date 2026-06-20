import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/monthly_budget.dart';
import '../utils/currency_format.dart';

class BudgetAlertService {
  factory BudgetAlertService() => _instance;

  BudgetAlertService._();

  static final BudgetAlertService _instance = BudgetAlertService._();
  static const _channelId = 'budget_alerts';
  static const _threshold = 0.8;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> maybeNotify({
    required MonthlyBudget budget,
    required double spent,
    required String categoryLabel,
  }) async {
    if (kIsWeb || budget.limit <= 0 || spent < budget.limit * _threshold) {
      return;
    }

    await initialize();
    final prefs = await SharedPreferences.getInstance();
    final alertKey = 'budget_alert_${budget.month}_${budget.category}';
    if (prefs.getBool(alertKey) ?? false) {
      return;
    }

    await _plugin.show(
      budget.id.hashCode,
      'Sap chay tui: $categoryLabel',
      'Da dung ${formatCurrency(spent)} / ${formatCurrency(budget.limit)}.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Budget alerts',
          channelDescription: 'Alerts when monthly spending reaches 80%.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    await prefs.setBool(alertKey, true);
  }
}
