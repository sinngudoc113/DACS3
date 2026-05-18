import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction_entry.dart';
import '../services/transaction_service.dart';
import '../utils/currency_format.dart';
import '../widgets/shared_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.service});

  final TransactionService? service;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final TransactionService _service;
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _typeFilter;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TransactionService.node(baseUrl: apiBaseUrl());
    _service.load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _delete(TransactionEntry entry) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.deleteTransaction(entry.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionDeleted)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionDeleteFailed('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        const DecorativeBackground(),
        SafeArea(
          child: ValueListenableBuilder<List<TransactionEntry>>(
            valueListenable: _service.listenable,
            builder: (context, transactions, _) {
              final filtered = _filterTransactions(transactions);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: l10n.historyTitle,
                      subtitle: l10n.historySubtitle,
                      trailing: const AppMenuButton(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: l10n.searchTransactions,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.allTransactions),
                          selected: _typeFilter == null,
                          onSelected: (_) => setState(() => _typeFilter = null),
                        ),
                        ChoiceChip(
                          label: Text(l10n.expense),
                          selected: _typeFilter == TransactionType.expense,
                          onSelected: (_) => setState(
                            () => _typeFilter = TransactionType.expense,
                          ),
                        ),
                        ChoiceChip(
                          label: Text(l10n.incomeType),
                          selected: _typeFilter == TransactionType.income,
                          onSelected: (_) => setState(
                            () => _typeFilter = TransactionType.income,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.historyCount(filtered.length),
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.noMatchingTransactions,
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6D7573),
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HistoryTile(
                            entry: entry,
                            onDelete: () => _delete(entry),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<TransactionEntry> _filterTransactions(
    List<TransactionEntry> transactions,
  ) {
    final filtered = transactions.where((entry) {
      final matchesType = _typeFilter == null || entry.type == _typeFilter;
      final haystack = '${entry.title} ${entry.note} ${entry.category}'
          .toLowerCase();
      final matchesQuery = _query.isEmpty || haystack.contains(_query);
      return matchesType && matchesQuery;
    }).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.onDelete});

  final TransactionEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isExpense = entry.type == TransactionType.expense;
    final amount = isExpense ? -entry.amount : entry.amount;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFB8335B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isExpense
                    ? const Color(0xFFFDECF1)
                    : const Color(0xFFE2F3EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isExpense ? Icons.trending_down : Icons.trending_up,
                color: isExpense
                    ? const Color(0xFFB8335B)
                    : const Color(0xFF0C6D6A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.categoryName(entry.category)} • ${_formatDate(entry.createdAt)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6D7573),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatSignedCurrency(amount),
              style: textTheme.titleMedium?.copyWith(
                color: isExpense
                    ? const Color(0xFFB8335B)
                    : const Color(0xFF0C6D6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
