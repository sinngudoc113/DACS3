import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/monthly_budget.dart';
import '../models/receipt_draft.dart';
import '../models/transaction_entry.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import '../services/receipt_ai_service.dart';
import '../services/transaction_service.dart';
import '../utils/currency_format.dart';
import '../widgets/shared_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.service,
    this.budgetService,
    this.onNavigateToTab,
  });

  final TransactionService? service;
  final BudgetService? budgetService;
  final ValueChanged<int>? onNavigateToTab;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _headerAnimation;
  late final Animation<double> _summaryAnimation;
  late final Animation<double> _actionsAnimation;
  late final Animation<double> _transactionsAnimation;
  late final TransactionService _service;
  late final BudgetService _budgetService;
  bool _isAnalyzingReceipt = false;
  final ReceiptAiService _receiptAiService = ReceiptAiService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TransactionService.node(baseUrl: apiBaseUrl());
    _budgetService =
        widget.budgetService ??
        (widget.service == null
            ? BudgetService.node(baseUrl: apiBaseUrl())
            : BudgetService.memory());
    _service.load();
    _budgetService.load();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _summaryAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
    );
    _actionsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
    );
    _transactionsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecorativeBackground(),
          SafeArea(
            child: ValueListenableBuilder<List<TransactionEntry>>(
              valueListenable: _service.listenable,
              builder: (context, transactions, _) {
                final l10n = AppLocalizations.of(context);
                final totals = _TransactionTotals.fromEntries(transactions);
                final userName =
                    AuthService().currentUser?.displayName.trim() ?? '';
                final greetingName = userName.isEmpty
                    ? l10n.defaultUserName
                    : userName;
                final summaryNote = transactions.isEmpty
                    ? l10n.noTransactionsSummary
                    : l10n.transactionsThisMonth(transactions.length);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSection(
                        animation: _headerAnimation,
                        child: _HeaderRow(name: greetingName),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSection(
                        animation: _summaryAnimation,
                        child: _SummaryCard(
                          l10n: l10n,
                          balance: totals.balance,
                          income: totals.income,
                          spent: totals.expense,
                          note: summaryNote,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSection(
                        animation: _actionsAnimation,
                        child: ValueListenableBuilder<List<MonthlyBudget>>(
                          valueListenable: _budgetService.listenable,
                          builder: (context, budgets, _) {
                            return _QuickActions(
                              l10n: l10n,
                              budgetPace: _BudgetPace.fromEntries(
                                transactions: transactions,
                                budgets: budgets,
                              ),
                              onNavigateToTab: widget.onNavigateToTab,
                              onScanReceipt: () => _showReceiptSheet(context),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSection(
                        animation: _transactionsAnimation,
                        child: _RecentTransactions(
                          items: transactions,
                          l10n: l10n,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isAnalyzingReceipt) const _ReceiptLoadingOverlay(),
        ],
      ),
    );
  }

  Future<void> _showReceiptSheet(BuildContext context) async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) {
        return;
      }

      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 60,
      );

      if (picked == null || !mounted) {
        return;
      }

      setState(() => _isAnalyzingReceipt = true);
      final draft = await _receiptAiService.analyzeReceiptWithAI(picked);
      if (!context.mounted) {
        return;
      }
      await _saveReceiptDraft(draft);
      if (!context.mounted) {
        return;
      }
      setState(() => _isAnalyzingReceipt = false);
      widget.onNavigateToTab?.call(2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu ${draft.items.length} mục từ hóa đơn.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      setState(() => _isAnalyzingReceipt = false);

      final message = error.toString();
      if (message.contains('RESOURCE_EXHAUSTED')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Hệ thống AI đang bận xử lý, vui lòng thử lại sau vài giây!',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể quét hóa đơn: $error')),
        );
      }
    }
  }

  Future<void> _saveReceiptDraft(ReceiptDraft draft) async {
    final now = DateTime.now();
    final parsedDate = draft.transactionDate;
    final isPlausibleReceiptDate =
        parsedDate != null &&
        !parsedDate.isBefore(DateTime(now.year - 1, 1, 1)) &&
        !parsedDate.isAfter(now.add(const Duration(days: 1)));
    final receiptDate = !isPlausibleReceiptDate
        ? now
        : DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
            now.hour,
            now.minute,
          );

    for (final item in draft.items) {
      final noteParts = [
        if (draft.merchant.isNotEmpty) draft.merchant,
        if (item.note.isNotEmpty) item.note,
        'Tự động từ AI quét hóa đơn',
      ];

      await _service.addTransaction(
        TransactionEntry(
          id: '',
          title: item.title.trim().isEmpty ? 'Mục hóa đơn' : item.title.trim(),
          amount: item.amount,
          type: TransactionType.expense,
          category: item.category,
          note: noteParts.join(' • '),
          createdAt: receiptDate,
          userId: '',
        ),
      );
    }
  }
}

class AnimatedSection extends StatelessWidget {
  const AnimatedSection({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.greeting(name),
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1E2D2B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.dashboardSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5C6B68),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const AppMenuButton(),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.l10n,
    required this.balance,
    required this.income,
    required this.spent,
    required this.note,
  });

  final AppLocalizations l10n;
  final double balance;
  final double income;
  final double spent;
  final String note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF0C6D6A), Color(0xFF0B3B47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C6D6A).withAlpha(38),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalBalance,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(210),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(balance),
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: l10n.income,
                  value: formatCurrency(income),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricPill(
                  label: l10n.spent,
                  value: formatCurrency(spent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.l10n,
    required this.budgetPace,
    this.onNavigateToTab,
    this.onScanReceipt,
  });

  final AppLocalizations l10n;
  final _BudgetPace budgetPace;
  final ValueChanged<int>? onNavigateToTab;
  final VoidCallback? onScanReceipt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.quickActions,
          actionLabel: l10n.seeAll,
          onTap: () => onNavigateToTab?.call(1),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActionTile(
              label: l10n.addTransactionAction,
              icon: Icons.add_circle_outline,
              color: const Color(0xFF0C6D6A),
              background: const Color(0xFFE2F3EE),
              hint: l10n.tapToOpen,
              onTap: () => onNavigateToTab?.call(1),
            ),
            _ActionTile(
              label: 'Quét hóa đơn',
              icon: Icons.qr_code_scanner_outlined,
              color: const Color(0xFF0E7FA3),
              background: const Color(0xFFD9F2F9),
              hint: 'AI tự nhập liệu',
              onTap: () => onScanReceipt?.call(),
            ),
            _ActionTile(
              label: l10n.categoriesAction,
              icon: Icons.grid_view_outlined,
              color: const Color(0xFF6F3D00),
              background: const Color(0xFFFFE6D6),
              hint: l10n.tapToOpen,
              onTap: () => onNavigateToTab?.call(1),
            ),
            _ActionTile(
              label: l10n.insightsAction,
              icon: Icons.insights_outlined,
              color: const Color(0xFF1C2C5B),
              background: const Color(0xFFE9EDFF),
              hint: l10n.tapToOpen,
              onTap: () => onNavigateToTab?.call(5),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECF1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFFB8335B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.budgetPace,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      budgetPace.hasBudget
                          ? l10n.budgetPaceSubtitle(budgetPace.percent)
                          : l10n.noBudgetYet,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6D7573),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: LinearProgressIndicator(
                        value: budgetPace.progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0F1F2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFB8335B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetPace {
  const _BudgetPace({required this.spent, required this.limit});

  final double spent;
  final double limit;

  bool get hasBudget => limit > 0;
  double get progress => hasBudget ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  int get percent => hasBudget ? ((spent / limit) * 100).round() : 0;

  factory _BudgetPace.fromEntries({
    required List<TransactionEntry> transactions,
    required List<MonthlyBudget> budgets,
  }) {
    final currentMonth = currentMonthKey();
    final currentBudgets = budgets
        .where((budget) => budget.month == currentMonth && budget.limit > 0)
        .toList(growable: false);

    final monthlyExpenses = transactions.where((transaction) {
      final transactionMonth =
          '${transaction.createdAt.year}-${transaction.createdAt.month.toString().padLeft(2, '0')}';
      return transaction.type == TransactionType.expense &&
          transactionMonth == currentMonth;
    });

    MonthlyBudget? overallBudget;
    for (final budget in currentBudgets) {
      if (budget.category == 'overall') {
        overallBudget = budget;
        break;
      }
    }

    if (overallBudget != null) {
      final spent = monthlyExpenses.fold<double>(
        0,
        (total, transaction) => total + transaction.amount,
      );
      return _BudgetPace(spent: spent, limit: overallBudget.limit);
    }

    final categoryBudgets = currentBudgets
        .where((budget) => budget.category != 'overall')
        .toList(growable: false);
    if (categoryBudgets.isEmpty) {
      return const _BudgetPace(spent: 0, limit: 0);
    }

    final budgetedCategories = categoryBudgets
        .map((budget) => budget.category)
        .toSet();
    final spent = monthlyExpenses
        .where(
          (transaction) => budgetedCategories.contains(transaction.category),
        )
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final limit = categoryBudgets.fold<double>(
      0,
      (total, budget) => total + budget.limit,
    );
    return _BudgetPace(spent: spent, limit: limit);
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: const Color(0xFF1E2D2B)),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5C6B68)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.items, required this.l10n});

  final List<TransactionEntry> items;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.recentTransactions,
          actionLabel: l10n.seeAll,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.noTransactions,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7573)),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TransactionTile(item: item, l10n: l10n),
            ),
          ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.l10n});

  final TransactionEntry item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isExpense = item.type == TransactionType.expense;
    final signedAmount = isExpense ? -item.amount : item.amount;
    final amountLabel = formatSignedCurrency(signedAmount);
    final categoryKey = _normalizeCategoryKey(item.category);
    final categoryStyle =
        _categoryStyles[categoryKey] ?? _categoryStyles['other']!;
    final categoryLabel = l10n.categoryName(categoryKey);
    final subtitle = item.note.isNotEmpty ? item.note : categoryLabel;

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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: categoryStyle.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(categoryStyle.icon, color: categoryStyle.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6D7573),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountLabel,
            style: textTheme.titleMedium?.copyWith(
              color: isExpense
                  ? const Color(0xFFB8335B)
                  : const Color(0xFF0C6D6A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textTheme.titleLarge),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0C6D6A),
            textStyle: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _TransactionTotals {
  const _TransactionTotals({required this.income, required this.expense});

  final double income;
  final double expense;

  double get balance => income - expense;

  factory _TransactionTotals.fromEntries(List<TransactionEntry> entries) {
    double income = 0;
    double expense = 0;

    for (final entry in entries) {
      if (entry.type == TransactionType.income) {
        income += entry.amount;
      } else {
        expense += entry.amount;
      }
    }

    return _TransactionTotals(income: income, expense: expense);
  }
}

class _ReceiptLoadingOverlay extends StatelessWidget {
  const _ReceiptLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(60),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              SizedBox(width: 12),
              Text('EggTrack AI đang đọc hóa đơn...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
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

final Map<String, _CategoryStyle> _categoryStyles = {
  'food': const _CategoryStyle(
    icon: Icons.restaurant_outlined,
    foreground: Color(0xFF7A3D00),
    background: Color(0xFFFFE6D6),
  ),
  'bills': const _CategoryStyle(
    icon: Icons.receipt_long_outlined,
    foreground: Color(0xFF1C2C5B),
    background: Color(0xFFE9EDFF),
  ),
  'travel': const _CategoryStyle(
    icon: Icons.train_outlined,
    foreground: Color(0xFF0C6D6A),
    background: Color(0xFFE2F3EE),
  ),
  'shopping': const _CategoryStyle(
    icon: Icons.shopping_bag_outlined,
    foreground: Color(0xFFB8335B),
    background: Color(0xFFFDECF1),
  ),
  'other': const _CategoryStyle(
    icon: Icons.auto_awesome_outlined,
    foreground: Color(0xFF1E2D2B),
    background: Color(0xFFF0F1F2),
  ),
};
