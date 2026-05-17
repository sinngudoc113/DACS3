enum TransactionType { expense, income }

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.createdAt,
    required this.userId,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String note;
  final DateTime createdAt;
  final String userId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String? ?? 'expense';
    final parsedType = TransactionType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => TransactionType.expense,
    );

    final rawCreatedAt = json['createdAt'] as String?;
    final createdAt = rawCreatedAt != null
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return TransactionEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: parsedType,
      category: json['category'] as String? ?? 'other',
      note: json['note'] as String? ?? '',
      createdAt: createdAt,
      userId: json['userId'] as String? ?? '',
    );
  }
}
