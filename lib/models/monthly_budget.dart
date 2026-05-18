class MonthlyBudget {
  const MonthlyBudget({
    required this.id,
    required this.month,
    required this.category,
    required this.limit,
    required this.userId,
  });

  final String id;
  final String month;
  final String category;
  final double limit;
  final String userId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'category': category,
      'limit': limit,
      'userId': userId,
    };
  }

  factory MonthlyBudget.fromJson(Map<String, dynamic> json) {
    return MonthlyBudget(
      id: json['id'] as String? ?? '',
      month: json['month'] as String? ?? _currentMonthKey(),
      category: json['category'] as String? ?? 'overall',
      limit: (json['limit'] as num?)?.toDouble() ?? 0,
      userId: json['userId'] as String? ?? '',
    );
  }
}

String currentMonthKey() => _currentMonthKey();

String _currentMonthKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  return '${now.year}-$month';
}
