import 'dart:math';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction_entry.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../utils/currency_format.dart';
import '../widgets/shared_widgets.dart';

enum StatsRange { week, month, year }

enum StatsMetric { income, expense, difference }

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.service, this.onNavigateHome});

  final TransactionService? service;
  final VoidCallback? onNavigateHome;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsRange _range = StatsRange.month;
  StatsMetric _metric = StatsMetric.expense;
  bool _compareSamePeriod = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
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
              final userEmail =
                  AuthService().currentUser?.email.trim().toLowerCase() ?? '';
              final scopedTransactions = userEmail.isEmpty
                  ? transactions
                  : transactions
                        .where(
                          (entry) =>
                              entry.userEmail.trim().toLowerCase() == userEmail,
                        )
                        .toList();
              final anchor = _anchorForRange(_range, _selectedMonth);
              final currentRange = _resolveRange(_range, anchor);
              final previousRange = _resolvePreviousRange(
                currentRange,
                _range,
                anchor,
              );
              final currentEntries = _filterTransactionsByRange(
                scopedTransactions,
                currentRange,
              );
              final previousEntries = _filterTransactionsByRange(
                scopedTransactions,
                previousRange,
              );
              final currentTotals = _StatsTotals.fromEntries(currentEntries);
              final selectedTotal = _metricValue(currentTotals, _metric);
              final totalColor = _metricColor(currentTotals, _metric);
              final categoryStats = _buildCategoryStatsForMetric(
                currentEntries,
                currentTotals,
                _metric,
              );
              final trend = _buildTrendSeries(
                currentEntries,
                previousEntries,
                currentRange,
                previousRange,
                _metric,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: l10n.statsTitle,
                      subtitle: l10n.insightsSubtitle,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppMenuButton(),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onNavigateHome,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.black.withAlpha(8),
                                ),
                              ),
                              child: const Icon(Icons.home_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SegmentedChipRow<StatsRange>(
                      value: _range,
                      items: [
                        _SegmentedChipItem(
                          value: StatsRange.week,
                          label: l10n.week,
                        ),
                        _SegmentedChipItem(
                          value: StatsRange.month,
                          label: l10n.month,
                        ),
                        _SegmentedChipItem(
                          value: StatsRange.year,
                          label: l10n.year,
                        ),
                      ],
                      onChanged: (value) => setState(() => _range = value),
                    ),
                    if (_range != StatsRange.week) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            _range == StatsRange.year
                                ? l10n.selectYear
                                : l10n.selectMonth,
                            style: textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF5C6B68),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _pickMonth(context),
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(_formatAnchorLabel()),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    _SegmentedChipRow<StatsMetric>(
                      value: _metric,
                      items: [
                        _SegmentedChipItem(
                          value: StatsMetric.income,
                          label: l10n.income,
                        ),
                        _SegmentedChipItem(
                          value: StatsMetric.expense,
                          label: l10n.expense,
                        ),
                        _SegmentedChipItem(
                          value: StatsMetric.difference,
                          label: l10n.difference,
                        ),
                      ],
                      onChanged: (value) => setState(() => _metric = value),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
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
                            _totalLabel(l10n, _metric, _range),
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF6B6B6B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _formatMetricCurrency(selectedTotal, _metric),
                            style: textTheme.displaySmall?.copyWith(
                              color: totalColor,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.trendTitle,
                                style: textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                l10n.compareSamePeriod,
                                style: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF7A7A7A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: _compareSamePeriod,
                                onChanged: (value) =>
                                    setState(() => _compareSamePeriod = value),
                                activeThumbColor: const Color(0xFF2DBE6C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 180,
                            child: _DualBarChart(
                              series: trend,
                              showComparison: _compareSamePeriod,
                              metric: _metric,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _MetricDetailSection(
                      metric: _metric,
                      l10n: l10n,
                      categoryStats: categoryStats,
                      transactions: currentEntries,
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

  DateTime _anchorForRange(StatsRange range, DateTime selectedMonth) {
    final now = DateTime.now();
    if (range == StatsRange.week) {
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(selectedMonth.year, selectedMonth.month, 1);
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null) {
      return;
    }
    setState(() => _selectedMonth = DateTime(picked.year, picked.month));
  }

  String _formatAnchorLabel() {
    if (_range == StatsRange.year) {
      return '${_selectedMonth.year}';
    }
    return '${_selectedMonth.month.toString().padLeft(2, '0')}/${_selectedMonth.year}';
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

double _metricValue(_StatsTotals totals, StatsMetric metric) {
  switch (metric) {
    case StatsMetric.income:
      return totals.income;
    case StatsMetric.expense:
      return totals.expense;
    case StatsMetric.difference:
      return totals.income - totals.expense;
  }
}

Color _metricColor(_StatsTotals totals, StatsMetric metric) {
  if (metric != StatsMetric.difference) {
    return const Color(0xFF1F1F1F);
  }
  if (totals.expense < totals.income) {
    return const Color(0xFF2DBE6C);
  }
  if (totals.expense > totals.income) {
    return const Color(0xFFFF6B6B);
  }
  return const Color(0xFF6B6B6B);
}

String _formatMetricCurrency(double value, StatsMetric metric) {
  if (metric != StatsMetric.difference) {
    return formatCurrency(value);
  }
  if (value == 0) {
    return formatCurrency(0);
  }
  return formatSignedCurrency(value);
}

_DateRange _resolveRange(StatsRange range, DateTime anchor) {
  switch (range) {
    case StatsRange.week:
      final start = DateTime(anchor.year, anchor.month, anchor.day);
      final end = DateTime(anchor.year, anchor.month, anchor.day, 23, 59, 59);
      return _DateRange(start: start, end: end);
    case StatsRange.month:
      final start = DateTime(anchor.year, anchor.month, 1);
      final end = DateTime(anchor.year, anchor.month + 1, 0, 23, 59, 59);
      return _DateRange(start: start, end: end);
    case StatsRange.year:
      final start = DateTime(anchor.year, 1, 1);
      final end = DateTime(anchor.year, 12, 31, 23, 59, 59);
      return _DateRange(start: start, end: end);
  }
}

_DateRange _resolvePreviousRange(
  _DateRange current,
  StatsRange range,
  DateTime anchor,
) {
  switch (range) {
    case StatsRange.week:
      return _DateRange(
        start: current.start.subtract(const Duration(days: 1)),
        end: current.end.subtract(const Duration(days: 1)),
      );
    case StatsRange.month:
      final prevAnchor = DateTime(anchor.year, anchor.month - 1, 1);
      final start = DateTime(prevAnchor.year, prevAnchor.month, 1);
      final end = DateTime(
        prevAnchor.year,
        prevAnchor.month + 1,
        0,
        23,
        59,
        59,
      );
      return _DateRange(start: start, end: end);
    case StatsRange.year:
      return _DateRange(
        start: DateTime(anchor.year - 1, 1, 1),
        end: DateTime(anchor.year - 1, 12, 31, 23, 59, 59),
      );
  }
}

List<TransactionEntry> _filterTransactionsByRange(
  List<TransactionEntry> entries,
  _DateRange range,
) {
  return entries
      .where(
        (entry) =>
            !entry.createdAt.isBefore(range.start) &&
            !entry.createdAt.isAfter(range.end),
      )
      .toList();
}

List<_CategoryStat> _buildCategoryStats(
  List<TransactionEntry> entries,
  double total,
) {
  final Map<String, double> totals = {};
  for (final entry in entries) {
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
          percent: total == 0 ? 0 : entry.value / total,
          color: _categoryColors[entry.key] ?? const Color(0xFF6D7573),
        ),
      )
      .toList();

  stats.sort((a, b) => b.amount.compareTo(a.amount));
  return stats;
}

List<_CategoryStat> _buildCategoryStatsForMetric(
  List<TransactionEntry> entries,
  _StatsTotals totals,
  StatsMetric metric,
) {
  if (metric == StatsMetric.difference) {
    return const [];
  }
  final filtered = entries
      .where(
        (entry) => metric == StatsMetric.income
            ? entry.type == TransactionType.income
            : entry.type == TransactionType.expense,
      )
      .toList();
  final total = metric == StatsMetric.income ? totals.income : totals.expense;
  return _buildCategoryStats(filtered, total);
}

List<_TrendPoint> _buildTrendSeries(
  List<TransactionEntry> current,
  List<TransactionEntry> previous,
  _DateRange range,
  _DateRange previousRange,
  StatsMetric metric,
) {
  final rangeBuckets = range.buckets;
  final buckets = rangeBuckets.length;
  final currentSeries = List<double>.filled(buckets, 0);
  final previousSeries = List<double>.filled(buckets, 0);
  for (final entry in current) {
    final index = range.bucketIndex(entry.createdAt);
    if (index == null) {
      continue;
    }
    currentSeries[index] += _entryMetricValue(entry, metric);
  }
  for (final entry in previous) {
    final index = previousRange.bucketIndex(entry.createdAt);
    if (index == null) {
      continue;
    }
    final alignedIndex = min(index, previousSeries.length - 1);
    previousSeries[alignedIndex] += _entryMetricValue(entry, metric);
  }
  final maxValue = [
    ...currentSeries,
    ...previousSeries,
  ].fold<double>(0, (value, element) => max(value, element.abs()));
  return List.generate(
    buckets,
    (index) => _TrendPoint(
      label: rangeBuckets[index].label,
      currentValue: currentSeries[index],
      previousValue: previousSeries[index],
      current: maxValue == 0
          ? 0
          : (currentSeries[index].abs() / maxValue).clamp(0.0, 1.0),
      previous: maxValue == 0
          ? 0
          : (previousSeries[index].abs() / maxValue).clamp(0.0, 1.0),
    ),
  );
}

double _entryMetricValue(TransactionEntry entry, StatsMetric metric) {
  switch (metric) {
    case StatsMetric.income:
      return entry.type == TransactionType.income ? entry.amount : 0;
    case StatsMetric.expense:
      return entry.type == TransactionType.expense ? entry.amount : 0;
    case StatsMetric.difference:
      return entry.type == TransactionType.income
          ? entry.amount
          : -entry.amount;
  }
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

class _SegmentedChipItem<T> {
  const _SegmentedChipItem({required this.value, required this.label});

  final T value;
  final String label;
}

class _SegmentedChipRow<T> extends StatelessWidget {
  const _SegmentedChipRow({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<_SegmentedChipItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(6)),
      ),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: item.value == value
                          ? const Color(0xFFFCE3EA)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: item.value == value
                            ? const Color(0xFFEB5D8A)
                            : const Color(0xFF6C6C6C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DualBarChart extends StatelessWidget {
  const _DualBarChart({
    required this.series,
    required this.showComparison,
    required this.metric,
  });

  final List<_TrendPoint> series;
  final bool showComparison;
  final StatsMetric metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: series
          .map(
            (point) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (showComparison)
                      FractionallySizedBox(
                        heightFactor: point.previous,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _barColor(point.previousValue, true),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    FractionallySizedBox(
                      heightFactor: point.current,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _barColor(point.currentValue, false),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Color _barColor(double value, bool comparison) {
    if (metric != StatsMetric.difference) {
      return comparison ? const Color(0xFFBBDCFB) : const Color(0xFF7FB5FF);
    }
    if (value > 0) {
      return comparison ? const Color(0xFFA9EBC5) : const Color(0xFF2DBE6C);
    }
    if (value < 0) {
      return comparison ? const Color(0xFFFFB4B4) : const Color(0xFFFF6B6B);
    }
    return const Color(0xFFD7DBDD);
  }
}

class _MetricDetailSection extends StatelessWidget {
  const _MetricDetailSection({
    required this.metric,
    required this.l10n,
    required this.categoryStats,
    required this.transactions,
  });

  final StatsMetric metric;
  final AppLocalizations l10n;
  final List<_CategoryStat> categoryStats;
  final List<TransactionEntry> transactions;

  @override
  Widget build(BuildContext context) {
    if (metric == StatsMetric.difference) {
      final sortedTransactions = [...transactions]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.historyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (sortedTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.noTransactions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6D7573),
                ),
              ),
            )
          else
            ...sortedTransactions.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TransactionDetailRow(entry: entry, l10n: l10n),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.childCategories,
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7573)),
            ),
          )
        else
          ...categoryStats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryBar(stat: stat),
            ),
          ),
      ],
    );
  }
}

class _TransactionDetailRow extends StatelessWidget {
  const _TransactionDetailRow({required this.entry, required this.l10n});

  final TransactionEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isExpense = entry.type == TransactionType.expense;
    final amount = isExpense ? -entry.amount : entry.amount;
    final color = isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF2DBE6C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isExpense
                  ? const Color(0xFFFFEFEF)
                  : const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              isExpense ? Icons.trending_down : Icons.trending_up,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '${l10n.categoryName(entry.category)} - ${_formatTransactionDate(entry.createdAt)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatSignedCurrency(amount),
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPoint {
  const _TrendPoint({
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.current,
    required this.previous,
  });

  final String label;
  final double currentValue;
  final double previousValue;
  final double current;
  final double previous;
}

class _DateRange {
  const _DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  List<_DateBucket> get buckets {
    final days = end.difference(start).inDays + 1;
    if (days == 1) {
      return List.generate(6, (index) {
        final bucketStart = DateTime(
          start.year,
          start.month,
          start.day,
          index * 4,
        );
        final bucketEnd = DateTime(
          start.year,
          start.month,
          start.day,
          index * 4 + 3,
          59,
          59,
        );
        return _DateBucket(
          label:
              '${bucketStart.hour.toString().padLeft(2, '0')}:00-${bucketEnd.hour.toString().padLeft(2, '0')}:59',
          range: _DateRange(start: bucketStart, end: bucketEnd),
        );
      });
    }

    if (days <= 7) {
      return List.generate(days, (index) {
        final day = DateTime(
          start.year,
          start.month,
          start.day,
        ).add(Duration(days: index));
        return _DateBucket(
          label:
              '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}',
          range: _DateRange(
            start: day,
            end: DateTime(day.year, day.month, day.day, 23, 59, 59),
          ),
        );
      });
    }

    if (days <= 31) {
      return List.generate(bucketCount, (index) {
        final bucketStart = DateTime(
          start.year,
          start.month,
          start.day,
        ).add(Duration(days: index * 7));
        final bucketEndDay = bucketStart.add(const Duration(days: 6));
        final cappedEnd = bucketEndDay.isAfter(end)
            ? end
            : DateTime(
                bucketEndDay.year,
                bucketEndDay.month,
                bucketEndDay.day,
                23,
                59,
                59,
              );
        return _DateBucket(
          label:
              '${bucketStart.day.toString().padLeft(2, '0')}-${cappedEnd.day.toString().padLeft(2, '0')}/${bucketStart.month.toString().padLeft(2, '0')}',
          range: _DateRange(start: bucketStart, end: cappedEnd),
        );
      });
    }

    return List.generate(12, (index) {
      final month = DateTime(start.year, index + 1, 1);
      return _DateBucket(
        label: '${month.month.toString().padLeft(2, '0')}/${month.year}',
        range: _DateRange(
          start: month,
          end: DateTime(month.year, month.month + 1, 0, 23, 59, 59),
        ),
      );
    });
  }

  int get bucketCount {
    final days = end.difference(start).inDays + 1;
    if (days == 1) {
      return 6;
    }
    if (days <= 7) {
      return days;
    }
    if (days <= 31) {
      return (days / 7).ceil();
    }
    return 12;
  }

  int? bucketIndex(DateTime date) {
    if (date.isBefore(start) || date.isAfter(end)) {
      return null;
    }
    final totalDays = end.difference(start).inDays + 1;
    if (totalDays == 1) {
      return max(0, min(date.hour ~/ 4, bucketCount - 1));
    }
    if (totalDays <= 7) {
      return date.difference(start).inDays;
    }
    if (totalDays <= 31) {
      final dayOffset = date.difference(start).inDays;
      final index = (dayOffset / 7).floor();
      return max(0, min(index, bucketCount - 1));
    }
    final monthIndex = (date.year - start.year) * 12 + date.month - start.month;
    return max(0, min(monthIndex, bucketCount - 1));
  }
}

class _DateBucket {
  const _DateBucket({required this.label, required this.range});

  final String label;
  final _DateRange range;
}

String _totalLabel(
  AppLocalizations l10n,
  StatsMetric metric,
  StatsRange range,
) {
  switch (metric) {
    case StatsMetric.income:
      return l10n.totalIncomeForRange(_currentRangeLabel(l10n, range));
    case StatsMetric.expense:
      return l10n.totalExpenseForRange(_currentRangeLabel(l10n, range));
    case StatsMetric.difference:
      return l10n.totalDifferenceForRange(_currentRangeLabel(l10n, range));
  }
}

String _currentRangeLabel(AppLocalizations l10n, StatsRange range) {
  switch (range) {
    case StatsRange.week:
      return l10n.currentWeek;
    case StatsRange.month:
      return l10n.currentMonth;
    case StatsRange.year:
      return l10n.currentYear;
  }
}

String _formatTransactionDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
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
