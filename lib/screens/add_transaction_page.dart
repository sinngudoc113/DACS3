import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction_entry.dart';
import '../services/transaction_service.dart';
import '../widgets/shared_widgets.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, this.service});

  final TransactionService? service;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TransactionService _service;

  TransactionType _type = TransactionType.expense;
  int _selectedCategory = 0;
  bool _isSaving = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<_CategoryOption> _categories = const [
    _CategoryOption(
      keyName: 'food',
      icon: Icons.restaurant_outlined,
      foreground: Color(0xFF7A3D00),
      background: Color(0xFFFFE6D6),
    ),
    _CategoryOption(
      keyName: 'bills',
      icon: Icons.receipt_long_outlined,
      foreground: Color(0xFF1C2C5B),
      background: Color(0xFFE9EDFF),
    ),
    _CategoryOption(
      keyName: 'travel',
      icon: Icons.train_outlined,
      foreground: Color(0xFF0C6D6A),
      background: Color(0xFFE2F3EE),
    ),
    _CategoryOption(
      keyName: 'shopping',
      icon: Icons.shopping_bag_outlined,
      foreground: Color(0xFFB8335B),
      background: Color(0xFFFDECF1),
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TransactionService.node(baseUrl: apiBaseUrl());
  }

  Future<void> _saveTransaction() async {
    final l10n = AppLocalizations.of(context);
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final rawAmount = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterValidAmount)));
      return;
    }

    setState(() => _isSaving = true);

    final entry = TransactionEntry(
      id: '',
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _categories[_selectedCategory].keyName,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
      userId: '',
    );

    try {
      await _service.addTransaction(entry);
      if (!mounted) {
        return;
      }
      _titleController.clear();
      _amountController.clear();
      _noteController.clear();
      setState(() => _selectedCategory = 0);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionSaved)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionSaveFailed('$error'))),
      );
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
    final accent = _type == TransactionType.expense
        ? const Color(0xFFB8335B)
        : const Color(0xFF0C6D6A);

    return Stack(
      children: [
        const DecorativeBackground(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: l10n.newTransaction,
                    subtitle: l10n.newTransactionSubtitle,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.calendar_today_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.typeLabel, style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text(l10n.expense),
                        icon: const Icon(Icons.trending_down),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(l10n.incomeType),
                        icon: const Icon(Icons.trending_up),
                      ),
                    ],
                    selected: {_type},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setState(() => _type = selection.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(MaterialState.selected)) {
                          return accent.withAlpha(24);
                        }
                        return Colors.white;
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(MaterialState.selected)) {
                          return accent;
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
                  Text(l10n.details, style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.titleLabel,
                      prefixIcon: const Icon(Icons.edit_note_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.enterTitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.amountLabel,
                      prefixIcon: const Icon(Icons.attach_money),
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.enterAmount;
                      }
                      final parsed = double.tryParse(
                        value.replaceAll(',', '').trim(),
                      );
                      if (parsed == null || parsed <= 0) {
                        return l10n.enterValidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.categoryLabel, style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(_categories.length, (index) {
                      final option = _categories[index];
                      final isSelected = _selectedCategory == index;
                      final categoryLabel = l10n.categoryName(option.keyName);

                      return ChoiceChip(
                        label: Text(categoryLabel),
                        avatar: Icon(
                          option.icon,
                          size: 18,
                          color: isSelected ? Colors.white : option.foreground,
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = index),
                        selectedColor: option.foreground,
                        backgroundColor: option.background,
                        labelStyle: textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : option.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.notesLabel, style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.noteHint,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InfoCard(
                    icon: Icons.schedule_outlined,
                    title: l10n.schedule,
                    subtitle: l10n.scheduleSubtitle,
                    accent: accent,
                  ),
                  const SizedBox(height: 20),
                  InfoCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.account,
                    subtitle: l10n.accountSubtitle,
                    accent: accent,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveTransaction,
                    child: Text(_isSaving ? l10n.saving : l10n.saveTransaction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryOption {
  const _CategoryOption({
    required this.keyName,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String keyName;
  final IconData icon;
  final Color foreground;
  final Color background;
}
