import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'firebase_options.dart';
import 'services/transaction_service.dart';
import 'state/locale_controller.dart';

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Firebase khong khoi tao duoc.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return FinanceApp(localeController: localeController);
      },
    );
  }
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key, required this.localeController, this.service});

  final LocaleController localeController;
  final TransactionService? service;

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return LocaleScope(
          controller: localeController,
          child: MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            locale: localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF14C8C3),
                brightness: Brightness.light,
              ),
              textTheme: baseTextTheme.copyWith(
                titleLarge: baseTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                titleMedium: baseTextTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.3),
                bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.3),
              ),
              scaffoldBackgroundColor: const Color(0xFFEFFFF9),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFB8EFE0),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? const Color(0xFF0F766E)
                      : const Color(0xFF6D7573);
                  return baseTextTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? const Color(0xFF0F766E)
                      : const Color(0xFF6D7573);
                  return IconThemeData(color: color);
                }),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12B7C8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.black.withAlpha(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF12B7C8),
                    width: 1.4,
                  ),
                ),
                labelStyle: baseTextTheme.bodySmall?.copyWith(
                  color: const Color(0xFF0B1F2A),
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            home: AuthGate(service: service),
          ),
        );
      },
    );
  }
}
