import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.provider,
  });

  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String provider;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: '${json['uid'] ?? ''}',
      email: '${json['email'] ?? ''}',
      displayName: '${json['displayName'] ?? ''}',
      role: '${json['role'] ?? 'user'}',
      provider: '${json['provider'] ?? 'local'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'provider': provider,
    };
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  factory AuthService() => _instance;

  AuthService._({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    http.Client? client,
    String? baseUrl,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? apiBaseUrl() {
    _auth.authStateChanges().listen((user) {
      // Nếu đang dùng local token thì không để Firebase override.
      if (_localToken != null) {
        return;
      }
      _currentUser = _userFromFirebase(user);
      _controller.add(_currentUser);
    });
  }

  static final AuthService _instance = AuthService._();

  static const _tokenKey = 'local_auth_token';
  static const _userKey = 'local_auth_user';

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final http.Client _client;
  final String _baseUrl;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;
  String? _localToken;
  bool _initialized = false;

  Stream<AppUser?> authStateChanges() => _controller.stream;

  AppUser? get currentUser => _currentUser;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (kIsWeb) {
      try {
        final redirectResult = await _auth.getRedirectResult();
        if (redirectResult.user != null) {
          _currentUser = _userFromFirebase(redirectResult.user);
          _controller.add(_currentUser);
          return;
        }
      } catch (_) {
        // Nếu redirect handling không có sẵn, tiếp tục với state đã lưu
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null && userJson != null) {
      _localToken = token;
      _currentUser = AppUser.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      _controller.add(_currentUser);
      return;
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = _userFromFirebase(firebaseUser);
      _controller.add(_currentUser);
      return;
    }

    _controller.add(null);
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    if (_localToken != null) {
      return _localToken;
    }

    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken(forceRefresh);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final data = await _postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    await _saveLocalSession(data);
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _postJson('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    await _saveLocalSession(data);
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _postJson('/auth/forgot-password', {'email': email});
    } catch (error) {
      throw AuthServiceException('500', 'Failed to send reset link');
    }
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _clearLocalSession();
      // Dùng popup với prompt select_account
      final googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      final userCredential = await _auth.signInWithPopup(googleProvider);
      _currentUser = _userFromFirebase(userCredential.user);
      _controller.add(_currentUser);
      return;
    }

    await _clearLocalSession();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    // Firebase auth state changes listener sẽ tự động update
  }

  Future<void> signOut() async {
    await _clearLocalSession();
    await _googleSignIn.signOut();
    await _auth.signOut();

    // Force reload để clear Google session trên web
    if (kIsWeb) {
      _currentUser = null;
      _controller.add(null);
      return;
    }

    _currentUser = null;
    _controller.add(null);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {'Content-Type': 'application/json', ...?headers},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));
    } on SocketException {
      throw const AuthServiceException(
        'network',
        'Cannot reach the server. Check API and emulator network.',
      );
    } on TimeoutException {
      throw const AuthServiceException(
        'timeout',
        'Server timeout. Please try again.',
      );
    }

    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        '${response.statusCode}',
        '${data['message'] ?? 'Authentication failed.'}',
      );
    }

    return data;
  }

  Future<void> _saveLocalSession(Map<String, dynamic> data) async {
    _localToken = data['token'] as String?;
    _currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _localToken ?? '');
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    await _auth.signOut();
    _controller.add(_currentUser);
  }

  Future<void> _clearLocalSession() async {
    _localToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  AppUser? _userFromFirebase(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email ?? 'User',
      role: 'user',
      provider: 'google',
    );
  }
}
