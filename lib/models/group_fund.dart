enum GroupFundTransactionType { expense, income }

class GroupFundMember {
  const GroupFundMember({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String uid;
  final String email;
  final String displayName;
  final String role;

  factory GroupFundMember.fromJson(Map<String, dynamic> json) {
    return GroupFundMember(
      uid: '${json['uid'] ?? ''}',
      email: '${json['email'] ?? ''}',
      displayName: '${json['displayName'] ?? json['email'] ?? ''}',
      role: '${json['role'] ?? 'member'}',
    );
  }
}

class GroupFundTransaction {
  const GroupFundTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.createdAt,
    required this.createdByEmail,
  });

  final String id;
  final String title;
  final double amount;
  final GroupFundTransactionType type;
  final String note;
  final DateTime createdAt;
  final String createdByEmail;

  factory GroupFundTransaction.fromJson(Map<String, dynamic> json) {
    final rawType = '${json['type'] ?? 'expense'}';
    return GroupFundTransaction(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? 'Group transaction'}',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: rawType == 'income'
          ? GroupFundTransactionType.income
          : GroupFundTransactionType.expense,
      note: '${json['note'] ?? ''}',
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      createdByEmail: '${json['createdByEmail'] ?? ''}',
    );
  }
}

class GroupFund {
  const GroupFund({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.balance,
    required this.members,
    required this.transactions,
  });

  final String id;
  final String name;
  final String ownerId;
  final double balance;
  final List<GroupFundMember> members;
  final List<GroupFundTransaction> transactions;

  factory GroupFund.fromJson(Map<String, dynamic> json) {
    return GroupFund(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      ownerId: '${json['ownerId'] ?? ''}',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      members: (json['members'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupFundMember.fromJson)
          .toList(growable: false),
      transactions: (json['transactions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupFundTransaction.fromJson)
          .toList(growable: false),
    );
  }
}
