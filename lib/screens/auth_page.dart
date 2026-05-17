import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/shared_widgets.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _service = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _service.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _service.registerWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(error, l10n))),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authError)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      await _service.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(error, l10n))),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authError)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapAuthError(FirebaseAuthException error, AppLocalizations l10n) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.authError;
      case 'email-already-in-use':
        return l10n.authEmailInUse;
      case 'weak-password':
        return l10n.passwordTooShort;
      default:
        return error.message ?? l10n.authError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const DecorativeBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: _isLogin ? l10n.authLoginTitle : l10n.authRegisterTitle,
                      subtitle: _isLogin
                          ? l10n.authLoginSubtitle
                          : l10n.authRegisterSubtitle,
                      trailing: const AppMenuButton(showSignOut: false),
                    ),
                    const SizedBox(height: 28),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: l10n.nameLabel),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: l10n.emailLabel),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (!value.contains('@')) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: l10n.passwordLabel),
                      obscureText: true,
                      textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (value.trim().length < 6) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmController,
                        decoration:
                            InputDecoration(labelText: l10n.confirmPasswordLabel),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField;
                          }
                          if (value.trim() != _passwordController.text.trim()) {
                            return l10n.passwordMismatch;
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(
                        _isLoading
                            ? l10n.processing
                            : (_isLogin ? l10n.loginButton : l10n.registerButton),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        l10n.orContinueWith,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata),
                      label: Text(l10n.googleSignIn),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? l10n.switchToRegister : l10n.switchToLogin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
