import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/group_fund.dart';
import '../services/group_fund_service.dart';
import '../utils/currency_format.dart';
import '../widgets/shared_widgets.dart';

class GroupFundPage extends StatefulWidget {
  const GroupFundPage({super.key, this.service});

  final GroupFundService? service;

  @override
  State<GroupFundPage> createState() => _GroupFundPageState();
}

class _GroupFundPageState extends State<GroupFundPage> {
  late final GroupFundService _service;
  final TextEditingController _fundNameController = TextEditingController();
  String? _error;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? GroupFundService(baseUrl: apiBaseUrl());
    _load();
  }

  @override
  void dispose() {
    _fundNameController.dispose();
    if (widget.service == null) {
      _service.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await _service.load();
    } catch (error) {
      if (mounted) {
        setState(() => _error = '$error');
      }
    }
  }

  Future<void> _createFund() async {
    final name = _fundNameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await _service.createFund(name);
      _fundNameController.clear();
      if (mounted) {
        setState(() => _error = null);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _inviteMember(GroupFund fund) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.inviteMember),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: l10n.memberEmail),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.inviteMember),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.isEmpty) {
      return;
    }

    try {
      await _service.inviteMember(fundId: fund.id, email: email);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  Future<void> _addFundTransaction(GroupFund fund) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    var type = GroupFundTransactionType.expense;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addFundTransaction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<GroupFundTransactionType>(
                segments: [
                  ButtonSegment(
                    value: GroupFundTransactionType.expense,
                    label: Text(l10n.expense),
                  ),
                  ButtonSegment(
                    value: GroupFundTransactionType.income,
                    label: Text(l10n.incomeType),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (value) =>
                    setDialogState(() => type = value.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: l10n.titleLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.amountLabel),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.saveTransaction),
            ),
          ],
        ),
      ),
    );

    final title = titleController.text.trim();
    final amount = double.tryParse(
      amountController.text.replaceAll(',', '').trim(),
    );
    titleController.dispose();
    amountController.dispose();

    if (submitted != true || title.isEmpty || amount == null || amount <= 0) {
      return;
    }

    try {
      await _service.addTransaction(
        fundId: fund.id,
        title: title,
        amount: amount,
        type: type,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: l10n.groupFundTitle,
                  subtitle: l10n.groupFundSubtitle,
                  trailing: const AppMenuButton(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createGroupFund, style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fundNameController,
                        decoration: InputDecoration(
                          labelText: l10n.groupFundName,
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isBusy ? null : _createFund,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createGroupFund),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB8335B),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ValueListenableBuilder<List<GroupFund>>(
                  valueListenable: _service.listenable,
                  builder: (context, funds, _) {
                    if (funds.isEmpty) {
                      return InfoCard(
                        icon: Icons.groups_2_outlined,
                        title: l10n.fundBalance,
                        subtitle: l10n.noGroupFunds,
                        accent: const Color(0xFF0C6D6A),
                      );
                    }

                    return Column(
                      children: funds
                          .map(
                            (fund) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _GroupFundCard(
                                fund: fund,
                                onInvite: () => _inviteMember(fund),
                                onAddTransaction: () =>
                                    _addFundTransaction(fund),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupFundCard extends StatelessWidget {
  const _GroupFundCard({
    required this.fund,
    required this.onInvite,
    required this.onAddTransaction,
  });

  final GroupFund fund;
  final VoidCallback onInvite;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(fund.name, style: textTheme.titleLarge)),
              Text(
                formatCurrency(fund.balance),
                style: textTheme.titleMedium?.copyWith(
                  color: fund.balance >= 0
                      ? const Color(0xFF0C6D6A)
                      : const Color(0xFFB8335B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.person_add_alt_1, size: 18),
                label: Text(l10n.inviteMember),
                onPressed: onInvite,
              ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: Text(l10n.addFundTransaction),
                onPressed: onAddTransaction,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(l10n.fundMembers, style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fund.members
                .map(
                  (member) => Chip(
                    avatar: Icon(
                      member.role == 'leader'
                          ? Icons.workspace_premium_outlined
                          : Icons.person_outline,
                      size: 18,
                    ),
                    label: Text(member.email),
                  ),
                )
                .toList(),
          ),
          if (fund.transactions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.recentTransactions, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            ...fund.transactions
                .take(4)
                .map((item) => _FundTransactionRow(transaction: item)),
          ],
        ],
      ),
    );
  }
}

class _FundTransactionRow extends StatelessWidget {
  const _FundTransactionRow({required this.transaction});

  final GroupFundTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == GroupFundTransactionType.expense;
    final amount = isExpense ? -transaction.amount : transaction.amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isExpense ? Icons.trending_down : Icons.trending_up,
            color: isExpense
                ? const Color(0xFFB8335B)
                : const Color(0xFF0C6D6A),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(transaction.title)),
          Text(formatSignedCurrency(amount)),
        ],
      ),
    );
  }
}
