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

class GroupFundParticipant {
  const GroupFundParticipant({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.amount,
    required this.paid,
  });

  final String uid;
  final String email;
  final String displayName;
  final double amount;
  final bool paid;

  factory GroupFundParticipant.fromJson(Map<String, dynamic> json) {
    return GroupFundParticipant(
      uid: '${json['uid'] ?? ''}',
      email: '${json['email'] ?? ''}',
      displayName: '${json['displayName'] ?? json['email'] ?? ''}',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paid: json['paid'] == true,
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
    required this.createdBy,
    required this.createdByName,
    required this.createdByEmail,
    required this.participants,
  });

  final String id;
  final String title;
  final double amount;
  final GroupFundTransactionType type;
  final String note;
  final DateTime createdAt;
  final String createdBy;
  final String createdByName;
  final String createdByEmail;
  final List<GroupFundParticipant> participants;

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
      createdBy: '${json['createdBy'] ?? ''}',
      createdByName: '${json['createdByName'] ?? ''}',
      createdByEmail: '${json['createdByEmail'] ?? ''}',
      participants: (json['participants'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupFundParticipant.fromJson)
          .toList(growable: false),
    );
  }
}

class GroupFund {
  const GroupFund({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.balance,
    required this.goalAmount,
    required this.members,
    required this.transactions,
  });

  final String id;
  final String name;
  final String ownerId;
  final double balance;
  final double goalAmount;
  final List<GroupFundMember> members;
  final List<GroupFundTransaction> transactions;

  factory GroupFund.fromJson(Map<String, dynamic> json) {
    return GroupFund(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      ownerId: '${json['ownerId'] ?? ''}',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      goalAmount: (json['goalAmount'] as num?)?.toDouble() ?? 0,
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
