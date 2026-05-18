import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import 'auth_page.dart';
import 'home_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.service});

  final TransactionService? service;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = AuthService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<AppUser?>(
          stream: authService.authStateChanges(),
          initialData: authService.currentUser,
          builder: (context, authSnapshot) {
            if (authSnapshot.data == null) {
              return const AuthPage();
            }

            return HomeShell(service: widget.service);
          },
        );
      },
    );
  }
}
