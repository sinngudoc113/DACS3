import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/transaction_entry.dart';
import 'auth_service.dart';

class TransactionService {
  TransactionService.node({
    required String baseUrl,
    AuthService? authService,
    http.Client? client,
  }) : _api = _TransactionApi(
         baseUrl: baseUrl,
         authService: authService ?? AuthService(),
         client: client ?? http.Client(),
       ),
       _store = ValueNotifier<List<TransactionEntry>>([]);

  TransactionService.memory({List<TransactionEntry>? seed})
    : _api = null,
      _store = ValueNotifier<List<TransactionEntry>>(seed ?? []);

  final _TransactionApi? _api;
  final ValueNotifier<List<TransactionEntry>> _store;
  bool _loaded = false;

  ValueListenable<List<TransactionEntry>> get listenable => _store;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    try {
      await refresh();
    } catch (_) {
      _store.value = const [];
    } finally {
      _loaded = true;
    }
  }

  Future<void> refresh() async {
    if (_api == null) {
      return;
    }
    final items = await _api.fetchTransactions();
    _store.value = items;
  }

  Future<void> addTransaction(TransactionEntry entry) async {
    if (_api == null) {
      _store.value = [entry, ..._store.value];
      return;
    }
    final created = await _api.createTransaction(entry);
    _store.value = [created, ..._store.value];
  }

  Future<void> updateTransaction(TransactionEntry entry) async {
    if (_api == null) {
      final updated = _store.value
          .map((item) => item.id == entry.id ? entry : item)
          .toList();
      _store.value = updated;
      return;
    }
    await _api.updateTransaction(entry);
    await refresh();
  }

  Future<void> deleteTransaction(String id) async {
    if (_api == null) {
      _store.value = _store.value.where((item) => item.id != id).toList();
      return;
    }
    await _api.deleteTransaction(id);
    await refresh();
  }
}

class _TransactionApi {
  _TransactionApi({
    required this.baseUrl,
    required this.authService,
    required this.client,
  });

  final String baseUrl;
  final AuthService authService;
  final http.Client client;

  Future<List<TransactionEntry>> fetchTransactions() async {
    final response = await client.get(
      Uri.parse('$baseUrl/transactions'),
      headers: await _headers(),
    );

    if (response.statusCode == 401) {
      final retryResponse = await client.get(
        Uri.parse('$baseUrl/transactions'),
        headers: await _headers(forceRefresh: true),
      );
      if (retryResponse.statusCode == 401) {
        return const [];
      }
      return _decodeTransactions(retryResponse);
    }

    return _decodeTransactions(response);
  }

  List<TransactionEntry> _decodeTransactions(http.Response response) {
    if (response.statusCode != 200) {
      throw StateError('Failed to load transactions (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => TransactionEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<TransactionEntry> createTransaction(TransactionEntry entry) async {
    final response = await client.post(
      Uri.parse('$baseUrl/transactions'),
      headers: await _headers(),
      body: jsonEncode(entry.toJson()),
    );

    if (response.statusCode != 201) {
      throw StateError(
        'Failed to create transaction (${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionEntry.fromJson(data);
  }

  Future<void> updateTransaction(TransactionEntry entry) async {
    final response = await client.put(
      Uri.parse('$baseUrl/transactions/${entry.id}'),
      headers: await _headers(),
      body: jsonEncode(entry.toJson()),
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Failed to update transaction (${response.statusCode}).',
      );
    }
  }

  Future<void> deleteTransaction(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw StateError(
        'Failed to delete transaction (${response.statusCode}).',
      );
    }
  }

  Future<Map<String, String>> _headers({bool forceRefresh = false}) async {
    final token = await authService.getIdToken(forceRefresh: forceRefresh);
    if (token == null) {
      throw StateError('User not authenticated.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
