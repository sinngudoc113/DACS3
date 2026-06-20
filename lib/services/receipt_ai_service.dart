import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../models/receipt_draft.dart';
import 'auth_service.dart';

class ReceiptAiService {
  ReceiptAiService({
    String? baseUrl,
    AuthService? authService,
    http.Client? client,
  }) : _baseUrl = baseUrl ?? apiBaseUrl(),
       _authService = authService ?? AuthService(),
       _client = client ?? http.Client();

  final String _baseUrl;
  final AuthService _authService;
  final http.Client _client;

  Future<ReceiptDraft> analyzeReceiptWithAI(XFile image) async {
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('Không tìm thấy ảnh hóa đơn.');
    }

    final token = await _authService.getIdToken();
    if (token == null) {
      throw Exception('Bạn cần đăng nhập trước khi quét hóa đơn.');
    }

    final response = await _client
        .post(
          Uri.parse('$_baseUrl/receipts/analyze'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'imageBase64': base64Encode(bytes),
            'mimeType': image.mimeType ?? _mimeTypeForName(image.name),
          }),
        )
        .timeout(const Duration(seconds: 45));

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final message =
          body['error'] ?? body['message'] ?? 'Không thể đọc hóa đơn.';
      throw Exception(message);
    }

    final draft = ReceiptDraft.fromJson(body);
    if (draft.items.isEmpty) {
      throw Exception('AI chưa đọc được dòng tiền nào từ hóa đơn.');
    }
    return draft;
  }

  String _mimeTypeForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
