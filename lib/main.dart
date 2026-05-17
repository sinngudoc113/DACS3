import 'package:flutter/material.dart';

import 'app.dart';
import 'state/locale_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = LocaleController();
  runApp(BootstrapApp(localeController: localeController));
}
