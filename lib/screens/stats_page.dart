import 'dart:math';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction_entry.dart';
import '../services/transaction_service.dart';
import '../utils/currency_format.dart';
import '../widgets/shared_widgets.dart';

enum StatsRange { week, month, year }

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.service});

  final TransactionService? service;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsRange _range = StatsRange.month;
  late final TransactionService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TransactionService.node(baseUrl: apiBaseUrl());
    _service.load();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        const DecorativeBackground(),
        SafeArea(
          child: ValueListenableBuilder<List<TransactionEntry>>(
            valueListenable: _service.listenable,
            builder: (context, transactions, _) {
              final filtered = _filterTransactions(transactions, _range);
              final totals = _StatsTotals.fromEntries(filtered);
              final categoryStats = _buildCategoryStats(
                filtered,
                totals.expense,
              );
              final trend = _buildTrend(filtered);
              const savingsTarget = 2000.0;
              final saved = totals.income - totals.expense;
              final savingsProgress = savingsTarget == 0
                  ? 0.0
                  : (saved / savingsTarget).clamp(0.0, 1.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: l10n.insightsTitle,
                      subtitle: l10n.insightsSubtitle,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppMenuButton(),
                          const SizedBox(width: 8),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.tune_outlined),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<StatsRange>(
                      segments: [
                        ButtonSegment(
                          value: StatsRange.week,
                          label: Text(l10n.week),
                        ),
                        ButtonSegment(
                          value: StatsRange.month,
                          label: Text(l10n.month),
                        ),
                        ButtonSegment(
                          value: StatsRange.year,
                          label: Text(l10n.year),
                        ),
                      ],
                      selected: {_range},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        setState(() => _range = selection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xFFE2F3EE);
                          }
                          return Colors.white;
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xFF0C6D6A);
                          }
                          return const Color(0xFF5C6B68);
                        }),
                        side: MaterialStateProperty.all(
                          BorderSide(color: Colors.black.withAlpha(12)),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0C6D6A), Color(0xFF0B3B47)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C6D6A).withAlpha(34),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalSpending,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white.withAlpha(210),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatCurrency(totals.expense),
                            style: textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatPill(
                                label: l10n.income,
                                value: formatCurrency(totals.income),
                              ),
                              const SizedBox(width: 12),
                              _StatPill(
                                label: l10n.saved,
                                value: formatCurrency(saved < 0 ? 0 : saved),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.monthlyTrend, style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.spendingPulse,
                            style: textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF1E2D2B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 140,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: trend
                                  .map(
                                    (value) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Container(
                                          height: 30 + value * 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF0C6D6A),
                                                const Color(
                                                  0xFF0B3B47,
                                                ).withAlpha(180),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.spendingByCategory, style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (categoryStats.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.noSpendingData,
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6D7573),
                          ),
                        ),
                      )
                    else
                      ...categoryStats
                          .map(
                            (stat) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CategoryBar(stat: stat),
                            ),
                          )
                          .toList(),
                    const SizedBox(height: 24),
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
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F3EE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.savings_outlined,
                              color: Color(0xFF0C6D6A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.savingsGoal,
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.savingsSubtitle(
                                    '\$${savingsTarget.toStringAsFixed(0)}',
                                  ),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF6D7573),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: LinearProgressIndicator(
                                    value: savingsProgress,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFF0F1F2),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0C6D6A),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(savingsProgress * 100).round()}%',
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF0C6D6A),
                            ),
                          ),
                        ],
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
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(28),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(200),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTotals {
  const _StatsTotals({required this.income, required this.expense});

  final double income;
  final double expense;

  factory _StatsTotals.fromEntries(List<TransactionEntry> entries) {
    double income = 0;
    double expense = 0;

    for (final entry in entries) {
      if (entry.type == TransactionType.income) {
        income += entry.amount;
      } else {
        expense += entry.amount;
      }
    }

    return _StatsTotals(income: income, expense: expense);
  }
}

List<TransactionEntry> _filterTransactions(
  List<TransactionEntry> entries,
  StatsRange range,
) {
  final now = DateTime.now();
  DateTime start;

  switch (range) {
    case StatsRange.week:
      start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      break;
    case StatsRange.month:
      start = DateTime(now.year, now.month, 1);
      break;
    case StatsRange.year:
      start = DateTime(now.year, 1, 1);
      break;
  }

  return entries
      .where(
        (entry) =>
            entry.createdAt.isAfter(start) ||
            entry.createdAt.isAtSameMomentAs(start),
      )
      .toList();
}

List<_CategoryStat> _buildCategoryStats(
  List<TransactionEntry> entries,
  double totalExpense,
) {
  final Map<String, double> totals = {};
  for (final entry in entries) {
    if (entry.type != TransactionType.expense) {
      continue;
    }
    final key = _normalizeCategoryKey(entry.category);
    totals.update(
      key,
      (value) => value + entry.amount,
      ifAbsent: () => entry.amount,
    );
  }

  final stats = totals.entries
      .map(
        (entry) => _CategoryStat(
          title: entry.key,
          amount: entry.value,
          percent: totalExpense == 0 ? 0 : entry.value / totalExpense,
          color: _categoryColors[entry.key] ?? const Color(0xFF6D7573),
        ),
      )
      .toList();

  stats.sort((a, b) => b.amount.compareTo(a.amount));
  return stats;
}

List<double> _buildTrend(List<TransactionEntry> entries) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final totals = List<double>.filled(7, 0);

  for (final entry in entries) {
    if (entry.type != TransactionType.expense) {
      continue;
    }

    final entryDay = DateTime(
      entry.createdAt.year,
      entry.createdAt.month,
      entry.createdAt.day,
    );
    final diff = today.difference(entryDay).inDays;
    if (diff >= 0 && diff < 7) {
      totals[6 - diff] += entry.amount;
    }
  }

  final maxTotal = totals.fold<double>(
    0,
    (value, element) => max(value, element),
  );
  if (maxTotal == 0) {
    return List<double>.filled(7, 0);
  }

  return totals.map((value) => value / maxTotal).toList();
}

String _normalizeCategoryKey(String value) {
  final normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'food':
      return 'food';
    case 'bills':
      return 'bills';
    case 'travel':
      return 'travel';
    case 'shopping':
      return 'shopping';
    case 'other':
      return 'other';
    default:
      return 'other';
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.stat});

  final _CategoryStat stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final label = l10n.categoryName(stat.title);

    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: textTheme.titleMedium),
              const Spacer(),
              Text(
                '\$${stat.amount.toStringAsFixed(0)}',
                style: textTheme.titleSmall?.copyWith(
                  color: stat.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: LinearProgressIndicator(
              value: stat.percent,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F1F2),
              valueColor: AlwaysStoppedAnimation<Color>(stat.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStat {
  const _CategoryStat({
    required this.title,
    required this.amount,
    required this.percent,
    required this.color,
  });

  final String title;
  final double amount;
  final double percent;
  final Color color;
}

const Map<String, Color> _categoryColors = {
  'food': Color(0xFF7A3D00),
  'bills': Color(0xFF1C2C5B),
  'travel': Color(0xFF0C6D6A),
  'shopping': Color(0xFFB8335B),
  'other': Color(0xFF6D7573),
};
