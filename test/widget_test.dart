// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dacs3/app.dart';
import 'package:dacs3/services/transaction_service.dart';
import 'package:dacs3/state/locale_controller.dart';

void main() {
  testWidgets('Finance app renders dashboard shell', (
    WidgetTester tester,
  ) async {
    final service = TransactionService.memory();
    final localeController = LocaleController(
      initialLocale: const Locale('en'),
    );

    await tester.pumpWidget(
      FinanceApp(localeController: localeController, service: service),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello, friend'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
  });
}
