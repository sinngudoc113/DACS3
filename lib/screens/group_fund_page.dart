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
  final TextEditingController _fundGoalController = TextEditingController();
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
    _fundGoalController.dispose();
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
    final goalAmount = double.tryParse(
      _fundGoalController.text.replaceAll(',', '').trim(),
    );
    if (name.isEmpty || goalAmount == null || goalAmount <= 0) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await _service.createFund(name: name, goalAmount: goalAmount);
      _fundNameController.clear();
      _fundGoalController.clear();
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

  Future<void> _setFundGoal(GroupFund fund) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: fund.goalAmount > 0 ? '${fund.goalAmount}' : '',
    );
    final goalAmount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setGroupFundGoal),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.groupFundGoal),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll(',', '').trim(),
              );
              Navigator.of(context).pop(value);
            },
            child: Text(l10n.setGroupFundGoal),
          ),
        ],
      ),
    );
    controller.dispose();

    if (goalAmount == null || goalAmount <= 0) {
      return;
    }

    try {
      await _service.setGoal(fundId: fund.id, goalAmount: goalAmount);
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
    final selectedMemberIds = fund.members.map((member) => member.uid).toSet();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addFundTransaction),
          content: SingleChildScrollView(
            child: Column(
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
                if (type == GroupFundTransactionType.expense) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.splitMembers),
                  ),
                  const SizedBox(height: 4),
                  ...fund.members.map(
                    (member) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: selectedMemberIds.contains(member.uid),
                      title: Text(_memberName(member)),
                      subtitle: Text(member.email),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedMemberIds.add(member.uid);
                          } else {
                            selectedMemberIds.remove(member.uid);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
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
        participantIds: type == GroupFundTransactionType.expense
            ? selectedMemberIds.toList(growable: false)
            : const [],
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
                      TextField(
                        controller: _fundGoalController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.groupFundGoal,
                          prefixIcon: const Icon(Icons.flag_outlined),
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
                                onSetGoal: () => _setFundGoal(fund),
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
    required this.onSetGoal,
    required this.onAddTransaction,
  });

  final GroupFund fund;
  final VoidCallback onInvite;
  final VoidCallback onSetGoal;
  final VoidCallback onAddTransaction;

  List<_MemberFundStats> get _memberStats {
    final totals = {for (final member in fund.members) member.uid: 0.0};

    for (final transaction in fund.transactions) {
      final sign = transaction.type == GroupFundTransactionType.income ? 1 : -1;
      for (final participant in _transactionParticipants(
        transaction,
        fund.members,
      )) {
        totals[participant.uid] =
            (totals[participant.uid] ?? 0) + participant.amount * sign;
      }
    }

    return fund.members
        .map(
          (member) => _MemberFundStats(
            member: member,
            balance: totals[member.uid] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  void _showMemberStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = _memberStats;
    final maxAbsBalance = stats.fold<double>(
      0,
      (maxValue, item) =>
          item.balance.abs() > maxValue ? item.balance.abs() : maxValue,
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.memberFundStats),
        content: SizedBox(
          width: 460,
          child: stats.isEmpty
              ? Text(l10n.noMemberHistory)
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: stats
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _MemberStatsRow(
                              stats: item,
                              maxAbsBalance: maxAbsBalance,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMemberHistory(BuildContext context, GroupFundMember member) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final relatedTransactions = fund.transactions
        .where((transaction) {
          final isCreator = transaction.createdBy == member.uid;
          final isParticipant = transaction.participants.any(
            (participant) => participant.uid == member.uid,
          );
          return isCreator || isParticipant;
        })
        .toList(growable: false);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.memberHistory(_memberName(member))),
        content: SizedBox(
          width: 420,
          child: relatedTransactions.isEmpty
              ? Text(l10n.noMemberHistory)
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: relatedTransactions.map((transaction) {
                      final isExpense =
                          transaction.type == GroupFundTransactionType.expense;
                      GroupFundParticipant? participant;
                      for (final item in transaction.participants) {
                        if (item.uid == member.uid) {
                          participant = item;
                          break;
                        }
                      }
                      final reasons = [
                        if (transaction.createdBy == member.uid)
                          l10n.createdByMember,
                        if (participant != null) l10n.includedInSplit,
                      ];

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isExpense ? Icons.trending_down : Icons.trending_up,
                          color: isExpense
                              ? const Color(0xFFB8335B)
                              : const Color(0xFF0C6D6A),
                        ),
                        title: Text(transaction.title),
                        subtitle: Text(reasons.join(' - ')),
                        trailing: Text(
                          participant == null
                              ? formatSignedCurrency(
                                  isExpense
                                      ? -transaction.amount
                                      : transaction.amount,
                                )
                              : formatCurrency(participant.amount),
                          style: textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final memberStats = _memberStats;

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
                fund.goalAmount > 0
                    ? '${formatCurrency(fund.balance)} / ${formatCurrency(fund.goalAmount)}'
                    : formatCurrency(fund.balance),
                style: textTheme.titleMedium?.copyWith(
                  color: fund.balance >= 0
                      ? const Color(0xFF0C6D6A)
                      : const Color(0xFFB8335B),
                ),
              ),
            ],
          ),
          if (fund.goalAmount > 0) ...[
            const SizedBox(height: 10),
            _FundGoalProgress(fund: fund),
          ],
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
              ActionChip(
                avatar: const Icon(Icons.flag_outlined, size: 18),
                label: Text(l10n.setGroupFundGoal),
                onPressed: onSetGoal,
              ),
              if (memberStats.isNotEmpty)
                ActionChip(
                  avatar: const Icon(Icons.bar_chart, size: 18),
                  label: Text(l10n.viewMemberFundStats),
                  onPressed: () => _showMemberStats(context),
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
                  (member) => ActionChip(
                    avatar: Icon(
                      member.role == 'leader'
                          ? Icons.workspace_premium_outlined
                          : Icons.person_outline,
                      size: 18,
                    ),
                    label: Text(member.email),
                    onPressed: () => _showMemberHistory(context, member),
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
                .map(
                  (item) => _FundTransactionRow(
                    transaction: item,
                    members: fund.members,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _MemberFundStats {
  const _MemberFundStats({required this.member, required this.balance});

  final GroupFundMember member;
  final double balance;
}

class _FundGoalProgress extends StatelessWidget {
  const _FundGoalProgress({required this.fund});

  final GroupFund fund;

  @override
  Widget build(BuildContext context) {
    final progress = fund.goalAmount <= 0
        ? 0.0
        : (fund.balance / fund.goalAmount).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final color = fund.balance >= fund.goalAmount
        ? const Color(0xFF0C6D6A)
        : const Color(0xFFB8335B);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${formatCurrency(fund.balance)} / ${formatCurrency(fund.goalAmount)}',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF687473),
              ),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: textTheme.bodyMedium?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFEFF5F4),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MemberStatsRow extends StatelessWidget {
  const _MemberStatsRow({required this.stats, required this.maxAbsBalance});

  final _MemberFundStats stats;
  final double maxAbsBalance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSurplus = stats.balance > 0;
    final isDeficit = stats.balance < 0;
    final color = isSurplus
        ? const Color(0xFF0C6D6A)
        : isDeficit
        ? const Color(0xFFB8335B)
        : const Color(0xFF687473);
    final status = isSurplus
        ? l10n.surplusStatus
        : isDeficit
        ? l10n.deficitStatus
        : l10n.balancedStatus;
    final widthFactor = maxAbsBalance <= 0
        ? 0.08
        : (stats.balance.abs() / maxAbsBalance).clamp(0.08, 1.0);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSurplus
                  ? Icons.trending_up
                  : isDeficit
                  ? Icons.trending_down
                  : Icons.horizontal_rule,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _memberName(stats.member),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$status ${formatSignedCurrency(stats.balance)}',
              style: textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: const Color(0xFFEFF5F4),
            alignment: isDeficit ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FundTransactionRow extends StatelessWidget {
  const _FundTransactionRow({required this.transaction, required this.members});

  final GroupFundTransaction transaction;
  final List<GroupFundMember> members;

  String get _creatorName {
    final explicitName = transaction.createdByName.trim();
    if (explicitName.isNotEmpty) {
      return explicitName;
    }

    for (final member in members) {
      if (member.uid == transaction.createdBy ||
          member.email == transaction.createdByEmail) {
        final memberName = member.displayName.trim();
        return memberName.isNotEmpty ? memberName : member.email;
      }
    }

    return transaction.createdByEmail.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == GroupFundTransactionType.expense;
    final amount = isExpense ? -transaction.amount : transaction.amount;
    final creatorName = _creatorName;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final participants = _transactionParticipants(transaction, members);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isExpense ? Icons.trending_down : Icons.trending_up,
                color: isExpense
                    ? const Color(0xFFB8335B)
                    : const Color(0xFF0C6D6A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title),
                    if (creatorName.isNotEmpty)
                      Text(
                        l10n.performedBy(creatorName),
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF687473),
                        ),
                      ),
                    if (participants.isNotEmpty &&
                        transaction.type == GroupFundTransactionType.expense)
                      Text(
                        l10n.splitShare(
                          formatCurrency(participants.first.amount),
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF687473),
                        ),
                      ),
                  ],
                ),
              ),
              Text(formatSignedCurrency(amount)),
            ],
          ),
          if (participants.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: participants.map((participant) {
                    final label = participant.displayName.isNotEmpty
                        ? participant.displayName
                        : participant.email;

                    if (transaction.type == GroupFundTransactionType.expense) {
                      return Chip(
                        avatar: const Icon(Icons.group_outlined, size: 16),
                        label: Text(
                          '$label - ${formatCurrency(participant.amount)}',
                        ),
                      );
                    }

                    return Chip(
                      avatar: const Icon(Icons.payments_outlined, size: 16),
                      label: Text(
                        '$label - ${formatCurrency(participant.amount)}',
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _memberName(GroupFundMember member) {
  final name = member.displayName.trim();
  return name.isNotEmpty ? name : member.email;
}

List<GroupFundParticipant> _transactionParticipants(
  GroupFundTransaction transaction,
  List<GroupFundMember> members,
) {
  if (transaction.participants.isNotEmpty) {
    return transaction.participants;
  }

  if (members.isEmpty) {
    return const [];
  }

  if (transaction.type == GroupFundTransactionType.income) {
    for (final member in members) {
      if (member.uid == transaction.createdBy ||
          member.email == transaction.createdByEmail) {
        return [
          GroupFundParticipant(
            uid: member.uid,
            email: member.email,
            displayName: _memberName(member),
            amount: transaction.amount,
            paid: true,
          ),
        ];
      }
    }
  }

  final share = transaction.amount / members.length;
  return members
      .map(
        (member) => GroupFundParticipant(
          uid: member.uid,
          email: member.email,
          displayName: _memberName(member),
          amount: share,
          paid: false,
        ),
      )
      .toList(growable: false);
}
