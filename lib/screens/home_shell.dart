import 'package:flutter/material.dart';

import 'add_transaction_page.dart';
import 'dashboard_page.dart';
import 'stats_page.dart';
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../services/transaction_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.service});

  final TransactionService? service;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final TransactionService _service;

  @override
  void initState() {
    super.initState();
    _service =
        widget.service ?? TransactionService.node(baseUrl: apiBaseUrl());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      DashboardPage(service: _service),
      AddTransactionPage(service: _service),
      StatsPage(service: _service),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: l10n.navAdd,
          ),
          NavigationDestination(
            icon: Icon(Icons.stacked_bar_chart_outlined),
            selectedIcon: Icon(Icons.stacked_bar_chart),
            label: l10n.navStats,
          ),
        ],
      ),
    );
  }
}
