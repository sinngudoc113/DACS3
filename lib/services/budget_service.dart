import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/monthly_budget.dart';
import 'auth_service.dart';

class BudgetService {
  BudgetService.node({
    required String baseUrl,
    AuthService? authService,
    http.Client? client,
  }) : _api = _BudgetApi(
         baseUrl: baseUrl,
         authService: authService ?? AuthService(),
         client: client ?? http.Client(),
       ),
       _store = ValueNotifier<List<MonthlyBudget>>([]);

  BudgetService.memory({List<MonthlyBudget>? seed})
    : _api = null,
      _store = ValueNotifier<List<MonthlyBudget>>(seed ?? []);

  final _BudgetApi? _api;
  final ValueNotifier<List<MonthlyBudget>> _store;
  bool _loaded = false;

  ValueListenable<List<MonthlyBudget>> get listenable => _store;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    await refresh();
  }

  Future<void> refresh() async {
    final api = _api;
    if (api == null) {
      return;
    }
    _store.value = await api.fetchBudgets();
  }

  Future<void> upsertBudget(MonthlyBudget budget) async {
    final api = _api;
    if (api == null) {
      final existing = _store.value.where(
        (item) =>
            item.month == budget.month && item.category == budget.category,
      );
      final next = _store.value
          .where(
            (item) =>
                item.month != budget.month || item.category != budget.category,
          )
          .toList();
      next.insert(
        0,
        MonthlyBudget(
          id: existing.isEmpty
              ? '${budget.month}-${budget.category}'
              : existing.first.id,
          month: budget.month,
          category: budget.category,
          limit: budget.limit,
          userId: budget.userId,
        ),
      );
      _store.value = next;
      return;
    }

    final saved = await api.upsertBudget(budget);
    final next = _store.value
        .where(
          (item) =>
              item.month != saved.month || item.category != saved.category,
        )
        .toList();
    next.insert(0, saved);
    _store.value = next;
  }
}

class _BudgetApi {
  _BudgetApi({
    required this.baseUrl,
    required this.authService,
    required this.client,
  });

  final String baseUrl;
  final AuthService authService;
  final http.Client client;

  Future<List<MonthlyBudget>> fetchBudgets() async {
    final response = await client.get(
      Uri.parse('$baseUrl/budgets'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw StateError('Failed to load budgets (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => MonthlyBudget.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<MonthlyBudget> upsertBudget(MonthlyBudget budget) async {
    final response = await client.put(
      Uri.parse('$baseUrl/budgets/${budget.month}/${budget.category}'),
      headers: await _headers(),
      body: jsonEncode(budget.toJson()),
    );

    if (response.statusCode != 200) {
      throw StateError('Failed to save budget (${response.statusCode}).');
    }

    return MonthlyBudget.fromJson(
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
}
