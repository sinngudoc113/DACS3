import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initialLocale})
    : _locale = initialLocale ?? const Locale('vi');

  Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('LocaleController not found in widget tree.');
    }
    return scope.notifier!;
  }
}
