import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/monthly_budget.dart';
import '../models/transaction_entry.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';
import '../utils/currency_format.dart';
import '../widgets/shared_widgets.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key, this.transactionService, this.budgetService});

  final TransactionService? transactionService;
  final BudgetService? budgetService;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late final TransactionService _transactionService;
  late final BudgetService _budgetService;
  final TextEditingController _limitController = TextEditingController();
  String _selectedCategory = 'overall';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _transactionService =
        widget.transactionService ??
        TransactionService.node(baseUrl: apiBaseUrl());
    _budgetService =
        widget.budgetService ?? BudgetService.node(baseUrl: apiBaseUrl());
    _transactionService.load();
    _budgetService.load();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final l10n = AppLocalizations.of(context);
    final rawAmount = _limitController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterValidAmount)));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _budgetService.upsertBudget(
        MonthlyBudget(
          id: '',
          month: currentMonthKey(),
          category: _selectedCategory,
          limit: amount,
          userId: '',
        ),
      );
      _limitController.clear();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.budgetSaved)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.budgetSaveFailed('$error'))));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
            valueListenable: _transactionService.listenable,
            builder: (context, transactions, _) {
              return ValueListenableBuilder<List<MonthlyBudget>>(
                valueListenable: _budgetService.listenable,
                builder: (context, budgets, _) {
                  final currentMonth = currentMonthKey();
                  final currentBudgets = budgets
                      .where((budget) => budget.month == currentMonth)
                      .toList();
                  final spending = _buildMonthlySpending(
                    transactions,
                    currentMonth,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: l10n.budgetTitle,
                          subtitle: l10n.budgetSubtitle,
                          trailing: const AppMenuButton(),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.setMonthlyBudget,
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: l10n.categoryLabel,
                                ),
                                items: _budgetCategories
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(
                                          _budgetCategoryLabel(l10n, category),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedCategory = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _limitController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.budgetLimitLabel,
                                  prefixIcon: const Icon(
                                    Icons.savings_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _saveBudget,
                                child: Text(
                                  _isSaving ? l10n.saving : l10n.saveBudget,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.currentBudgetProgress,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (currentBudgets.isEmpty)
                          _EmptyBudgetCard(message: l10n.noBudgetYet)
                        else
                          ...currentBudgets.map((budget) {
                            final spent = budget.category == 'overall'
                                ? spending.values.fold<double>(
                                    0,
                                    (sum, value) => sum + value,
                                  )
                                : spending[budget.category] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _BudgetProgressCard(
                                title: _budgetCategoryLabel(
                                  l10n,
                                  budget.category,
                                ),
                                spent: spent,
                                limit: budget.limit,
                              ),
                            );
                          }),
                        const SizedBox(height: 12),
                        _ReminderCard(
                          title: l10n.dailyReminder,
                          subtitle: l10n.dailyReminderSubtitle,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({
    required this.title,
    required this.spent,
    required this.limit,
  });

  final String title;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final isOver = spent > limit;
    final color = isOver ? const Color(0xFFB8335B) : const Color(0xFF0C6D6A);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              Text(
                '${(progress * 100).round()}%',
                style: textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${formatCurrency(spent)} / ${formatCurrency(limit)}',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6D7573),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFF0F1F2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetCard extends StatelessWidget {
  const _EmptyBudgetCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7573)),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.notifications_active_outlined,
      title: title,
      subtitle: subtitle,
      accent: const Color(0xFFB8335B),
    );
  }
}

Map<String, double> _buildMonthlySpending(
  List<TransactionEntry> transactions,
  String month,
) {
  final totals = <String, double>{};
  for (final item in transactions) {
    final itemMonth =
        '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}';
    if (itemMonth != month || item.type != TransactionType.expense) {
      continue;
    }
    final category = _budgetCategories.contains(item.category)
        ? item.category
        : 'other';
    totals.update(
      category,
      (value) => value + item.amount,
      ifAbsent: () => item.amount,
    );
  }
  return totals;
}

String _budgetCategoryLabel(AppLocalizations l10n, String category) {
  if (category == 'overall') {
    return l10n.overallBudget;
  }
  return l10n.categoryName(category);
}

const List<String> _budgetCategories = [
  'overall',
  'food',
  'bills',
  'travel',
  'shopping',
  'other',
];
