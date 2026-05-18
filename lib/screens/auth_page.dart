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
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapLocalServiceError(error, l10n))),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mapAuthError(error, l10n))));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authError)));
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
      
      // Đợi để Firebase cập nhật state
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // AuthGate sẽ tự động detect user change và navigate
        // Không cần làm gì thêm
      }
    } on AuthServiceException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.googleAuthError)),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(error, l10n))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.googleAuthError)),
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

  String _mapLocalServiceError(AuthServiceException error, AppLocalizations l10n) {
    switch (error.code) {
      case '401':
      case '404':
        return l10n.invalidLogin;
      case '400':
        return l10n.authError;
      case '409':
        return l10n.authEmailInUse;
      default:
        return error.message.isEmpty ? l10n.authError : error.message;
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.resetPasswordTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.resetPasswordSubtitle),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.switchToLogin.split('?')[0]),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(l10n.invalidEmail)),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _service.resetPassword(email: email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.resetPasswordSent)),
                  );
                }
              },
              child: Text(l10n.loginButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const DecorativeBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 52,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(246),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.black.withAlpha(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0B3B47).withAlpha(22),
                                blurRadius: 36,
                                offset: const Offset(0, 24),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2F3EE),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Icons.savings_outlined,
                                        color: Color(0xFF0C6D6A),
                                      ),
                                    ),
                                    const AppMenuButton(showSignOut: false),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _isLogin
                                      ? l10n.authLoginTitle
                                      : l10n.authRegisterTitle,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: const Color(0xFF1E2D2B),
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _isLogin
                                      ? l10n.authLoginSubtitle
                                      : l10n.authRegisterSubtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5C6B68),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: !_isLogin
                                      ? Column(
                                          key: const ValueKey('name-field'),
                                          children: [
                                            _AuthTextField(
                                              controller: _nameController,
                                              label: l10n.nameLabel,
                                              icon: Icons.person_outline,
                                              textInputAction:
                                                  TextInputAction.next,
                                            ),
                                            const SizedBox(height: 14),
                                          ],
                                        )
                                      : const SizedBox.shrink(
                                          key: ValueKey('empty-name-field'),
                                        ),
                                ),
                                _AuthTextField(
                                  controller: _emailController,
                                  label: l10n.emailLabel,
                                  icon: Icons.mail_outline,
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
                                const SizedBox(height: 14),
                                _AuthTextField(
                                  controller: _passwordController,
                                  label: l10n.passwordLabel,
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  textInputAction: _isLogin
                                      ? TextInputAction.done
                                      : TextInputAction.next,
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
                                if (_isLogin)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _showForgotPasswordDialog,
                                        child: Text(l10n.forgotPassword),
                                      ),
                                    ),
                                  ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: !_isLogin
                                      ? Column(
                                          key: const ValueKey('confirm-field'),
                                          children: [
                                            const SizedBox(height: 14),
                                            _AuthTextField(
                                              controller: _confirmController,
                                              label: l10n.confirmPasswordLabel,
                                              icon:
                                                  Icons.verified_user_outlined,
                                              obscureText: true,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return l10n.requiredField;
                                                }
                                                if (value.trim() !=
                                                    _passwordController.text
                                                        .trim()) {
                                                  return l10n.passwordMismatch;
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(
                                          key: ValueKey('empty-confirm-field'),
                                        ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    child: Text(
                                      _isLoading
                                          ? l10n.processing
                                          : (_isLogin
                                                ? l10n.loginButton
                                                : l10n.registerButton),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.black.withAlpha(22),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        l10n.orContinueWith,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF6D7573),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.black.withAlpha(22),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : _signInWithGoogle,
                                    icon: const Icon(Icons.g_mobiledata),
                                    label: Text(l10n.googleSignIn),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1E2D2B),
                                      side: BorderSide(
                                        color: Colors.black.withAlpha(24),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Center(
                                  child: TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => setState(
                                            () => _isLogin = !_isLogin,
                                          ),
                                    child: Text(
                                      _isLogin
                                          ? l10n.switchToRegister
                                          : l10n.switchToLogin,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0C6D6A)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }
}
