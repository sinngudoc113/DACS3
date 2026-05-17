import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/transaction_service.dart';
import 'auth_page.dart';
import 'home_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.service});

  final TransactionService? service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const AuthPage();
        }

        return HomeShell(service: service);
      },
    );
  }
}
