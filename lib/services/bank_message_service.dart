import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/transaction_entry.dart';

class BankMessageDraft {
  const BankMessageDraft({
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.createdAt,
    this.category = 'other',
  });

  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String note;
  final DateTime createdAt;
}

class BankMessageService {
  static const _channel = MethodChannel('dacs3/bank_messages');
  static const _notifications = EventChannel('dacs3/bank_notifications');

  Stream<BankMessageDraft> watchNotificationDrafts() {
    var lastSignature = '';
    return _notifications
        .receiveBroadcastStream()
        .where((event) => event is Map<dynamic, dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map(
          (item) => _parseMessage(
            sender: '${item['sender'] ?? 'Notification'}',
            body: '${item['body'] ?? ''}',
            timestampMs: item['timestampMs'] is num
                ? (item['timestampMs'] as num).toInt()
                : null,
          ),
        )
        .where((draft) => draft != null)
        .cast<BankMessageDraft>()
        .where((draft) {
          final signature =
              '${draft.amount}-${draft.type.name}-${draft.createdAt.millisecondsSinceEpoch}-${draft.note}';
          if (signature == lastSignature) {
            return false;
          }
          lastSignature = signature;
          return true;
        });
  }

  Future<bool> isNotificationAccessEnabled() async {
    if (kIsWeb) {
      return false;
    }
    return await _channel.invokeMethod<bool>('isNotificationAccessEnabled') ??
        false;
  }

  Future<void> openNotificationAccessSettings() async {
    if (kIsWeb) {
      return;
    }
    await _channel.invokeMethod<void>('openNotificationAccessSettings');
  }

  Future<List<BankMessageDraft>> readRecentDrafts({int limit = 50}) async {
    if (kIsWeb) {
      return const [];
    }

    final messages = await _channel.invokeMethod<List<dynamic>>(
      'readRecentSms',
      {'limit': limit},
    );

    return (messages ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => _parseMessage(
            sender: '${item['sender'] ?? ''}',
            body: '${item['body'] ?? ''}',
            timestampMs: item['timestampMs'] is num
                ? (item['timestampMs'] as num).toInt()
                : null,
          ),
        )
        .whereType<BankMessageDraft>()
        .toList(growable: false);
  }

  BankMessageDraft? parseText(String text) {
    return _parseMessage(sender: 'Manual', body: text, timestampMs: null);
  }

  BankMessageDraft? _parseMessage({
    required String sender,
    required String body,
    required int? timestampMs,
  }) {
    final normalized = body.toLowerCase();
    final isBankLike =
        normalized.contains('stk') ||
        normalized.contains('tai khoan') ||
        normalized.contains('tài khoản') ||
        normalized.contains('so du') ||
        normalized.contains('số dư') ||
        normalized.contains('momo') ||
        normalized.contains('zalopay') ||
        normalized.contains('zalo pay') ||
        normalized.contains('vnd');

    if (!isBankLike) {
      return null;
    }

    final type = _detectType(normalized);
    if (type == null) {
      return null;
    }

    final amount = _extractAmount(body, type);
    if (amount == null || amount <= 0) {
      return null;
    }

    final merchant = _extractMerchant(body);
    final title = merchant.isEmpty
        ? (type == TransactionType.income
              ? 'Tiền vào từ ngân hàng'
              : 'Tiền ra từ ngân hàng')
        : merchant;

    return BankMessageDraft(
      title: title,
      amount: amount,
      type: type,
      category: _inferCategory(body, merchant, type),
      note: 'Tu dong doc tu $sender: $body',
      createdAt: timestampMs == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
  }

  TransactionType? _detectType(String text) {
    final expenseSignals = [
      'gd:',
      'chi',
      'tru',
      'trừ',
      'debit',
      'withdraw',
      'thanh toan',
      'thanh toán',
      'chuyen tien',
      'chuyển tiền',
      '-',
    ];
    final incomeSignals = [
      'cong',
      'cộng',
      'credit',
      'nhan',
      'nhận',
      'tien vao',
      'tiền vào',
      '+',
    ];

    if (expenseSignals.any(text.contains)) {
      return TransactionType.expense;
    }
    if (incomeSignals.any(text.contains)) {
      return TransactionType.income;
    }
    return null;
  }

  String _inferCategory(String body, String merchant, TransactionType type) {
    if (type == TransactionType.income) {
      return 'other';
    }

    final text = '${body.toLowerCase()} ${merchant.toLowerCase()}';
    final foodSignals = [
      'food',
      'restaurant',
      'cafe',
      'coffee',
      'tra sua',
      'trà sữa',
      'quan an',
      'quán ăn',
      'com',
      'cơm',
      'bun',
      'bún',
      'pho',
      'phở',
      'grabfood',
      'shopeefood',
      'befood',
      'kfc',
      'lotteria',
      'highlands',
    ];
    final billSignals = [
      'bill',
      'hoa don',
      'hóa đơn',
      'dien',
      'điện',
      'nuoc',
      'nước',
      'internet',
      'wifi',
      'mobile',
      'nap tien',
      'nạp tiền',
      'viettel',
      'mobifone',
      'vinaphone',
    ];
    final travelSignals = [
      'grab',
      'be ',
      'taxi',
      'xanh sm',
      'gojek',
      'bus',
      'xe',
      'xang',
      'xăng',
      'parking',
      've xe',
      'vé xe',
    ];
    final shoppingSignals = [
      'shop',
      'shopping',
      'shopee',
      'lazada',
      'tiki',
      'sieu thi',
      'siêu thị',
      'winmart',
      'bach hoa',
      'bách hóa',
      'circle k',
      'gs25',
      'ministop',
    ];

    if (foodSignals.any(text.contains)) {
      return 'food';
    }
    if (billSignals.any(text.contains)) {
      return 'bills';
    }
    if (travelSignals.any(text.contains)) {
      return 'travel';
    }
    if (shoppingSignals.any(text.contains)) {
      return 'shopping';
    }
    return 'other';
  }

  double? _extractAmount(String body, TransactionType type) {
    final sign = type == TransactionType.income ? r'\+' : r'[-−]';
    final signedPattern = RegExp(
      '$sign\\s*([0-9][0-9.,]{2,})\\s*(?:vnd|đ|d)?',
      caseSensitive: false,
    );
    final signedMatch = signedPattern.firstMatch(body);
    if (signedMatch != null) {
      return _parseMoney(signedMatch.group(1));
    }

    final labeledPattern = RegExp(
      r'(?:so tien|số tiền|amount|gd|giao dich|giao dịch)[:\s]*([0-9][0-9.,]{2,})\s*(?:vnd|đ|d)?',
      caseSensitive: false,
    );
    final labeledMatch = labeledPattern.firstMatch(body);
    if (labeledMatch != null) {
      return _parseMoney(labeledMatch.group(1));
    }

    final genericPattern = RegExp(
      r'([0-9][0-9.,]{2,})\s*(?:vnd|đ|d)',
      caseSensitive: false,
    );
    final genericMatch = genericPattern.firstMatch(body);
    return genericMatch == null ? null : _parseMoney(genericMatch.group(1));
  }

  double? _parseMoney(String? raw) {
    if (raw == null) {
      return null;
    }
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }
    return double.tryParse(digits);
  }

  String _extractMerchant(String body) {
    final patterns = [
      RegExp(
        r'(?:tai|tại|to|den|đến)\s+([^.;,\n]{3,40})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:noi dung|nội dung|nd)[:\s]+([^.;\n]{3,50})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }
}
