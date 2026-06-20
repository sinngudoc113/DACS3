class ReceiptDraft {
  const ReceiptDraft({
    required this.merchant,
    required this.transactionDate,
    required this.items,
  });

  final String merchant;
  final DateTime? transactionDate;
  final List<ReceiptDraftItem> items;

  factory ReceiptDraft.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawDate = json['transactionDate'] as String? ?? '';

    return ReceiptDraft(
      merchant: json['merchant'] as String? ?? '',
      transactionDate: DateTime.tryParse(rawDate),
      items: rawItems
          .map(
            (item) => ReceiptDraftItem.fromJson(item as Map<String, dynamic>),
          )
          .where((item) => item.amount > 0)
          .toList(growable: false),
    );
  }
}

class ReceiptDraftItem {
  const ReceiptDraftItem({
    required this.title,
    required this.amount,
    required this.category,
    required this.note,
  });

  final String title;
  final double amount;
  final String category;
  final String note;

  factory ReceiptDraftItem.fromJson(Map<String, dynamic> json) {
    return ReceiptDraftItem(
      title: json['title'] as String? ?? 'Mục hóa đơn',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'other',
      note: json['note'] as String? ?? '',
    );
  }
}
