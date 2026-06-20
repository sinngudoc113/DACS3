import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/group_fund.dart';
import 'auth_service.dart';

class GroupFundService {
  GroupFundService({
    required String baseUrl,
    AuthService? authService,
    http.Client? client,
  }) : _api = _GroupFundApi(
         baseUrl: baseUrl,
         authService: authService ?? AuthService(),
         client: client ?? http.Client(),
       );

  final _GroupFundApi _api;
  final ValueNotifier<List<GroupFund>> _store = ValueNotifier([]);
  Timer? _pollTimer;

  ValueListenable<List<GroupFund>> get listenable => _store;

  Future<void> load({bool realtime = true}) async {
    await refresh();
    if (realtime) {
      _pollTimer ??= Timer.periodic(
        const Duration(seconds: 8),
        (_) => refresh(silent: true),
      );
    }
  }

  Future<void> refresh({bool silent = false}) async {
    try {
      _store.value = await _api.fetchFunds();
    } catch (error) {
      if (!silent) {
        rethrow;
      }
    }
  }

  Future<void> createFund(String name) async {
    final fund = await _api.createFund(name);
    _store.value = [fund, ..._store.value];
  }

  Future<void> inviteMember({
    required String fundId,
    required String email,
  }) async {
    final fund = await _api.inviteMember(fundId: fundId, email: email);
    _replaceFund(fund);
  }

  Future<void> addTransaction({
    required String fundId,
    required String title,
    required double amount,
    required GroupFundTransactionType type,
    String note = '',
  }) async {
    final fund = await _api.addTransaction(
      fundId: fundId,
      title: title,
      amount: amount,
      type: type,
      note: note,
    );
    _replaceFund(fund);
  }

  void dispose() {
    _pollTimer?.cancel();
    _store.dispose();
  }

  void _replaceFund(GroupFund fund) {
    _store.value = _store.value
        .map((item) => item.id == fund.id ? fund : item)
        .toList(growable: false);
  }
}

class _GroupFundApi {
  _GroupFundApi({
    required this.baseUrl,
    required this.authService,
    required this.client,
  });

  final String baseUrl;
  final AuthService authService;
  final http.Client client;

  Future<List<GroupFund>> fetchFunds() async {
    final response = await client.get(
      Uri.parse('$baseUrl/group-funds'),
      headers: await _headers(),
    );
    _throwIfFailed(response, 200);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => GroupFund.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<GroupFund> createFund(String name) async {
    final response = await client.post(
      Uri.parse('$baseUrl/group-funds'),
      headers: await _headers(),
      body: jsonEncode({'name': name}),
    );
    _throwIfFailed(response, 201);
    return GroupFund.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<GroupFund> inviteMember({
    required String fundId,
    required String email,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/group-funds/$fundId/invite'),
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    );
    _throwIfFailed(response, 200);
    return GroupFund.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<GroupFund> addTransaction({
    required String fundId,
    required String title,
    required double amount,
    required GroupFundTransactionType type,
    required String note,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/group-funds/$fundId/transactions'),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'type': type.name,
        'note': note,
      }),
    );
    _throwIfFailed(response, 201);
    return GroupFund.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await authService.getIdToken();
    if (token == null) {
      throw StateError('User not authenticated.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _throwIfFailed(http.Response response, int expectedStatus) {
    if (response.statusCode == expectedStatus) {
      return;
    }
    final message = response.body.isEmpty
        ? 'Request failed (${response.statusCode}).'
        : '${jsonDecode(response.body)['message'] ?? 'Request failed'}';
    throw StateError(message);
  }
}
