import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../session.dart';
import 'client_factory.dart';

class ApiException implements Exception {
  final int status;
  final String code, message;
  final int retryAfter;
  const ApiException(
    this.status,
    this.code,
    this.message, [
    this.retryAfter = 0,
  ]);
  @override
  String toString() => message;
}

class Transport {
  final HostSession session;
  final http.Client client;
  final storage = const FlutterSecureStorage();
  Transport(this.session, {http.Client? client})
    : client = client ?? createHttpClient();
  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '${Config.apiUrl}$path',
    ).replace(queryParameters: query);
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = path.startsWith('/auth/') ? null : await session.token();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final parts = path.split('/');
    final code = parts.length > 2 && parts[1] == 'rooms' ? parts[2] : null;
    if (!kIsWeb && code != null) {
      final guest = await storage.read(key: 'qit.guest.$code');
      if (guest != null) headers['X-Guest-Token'] = guest;
    }
    try {
      final req = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) req.body = jsonEncode(body);
      final response = await http.Response.fromStream(
        await client.send(req).timeout(const Duration(seconds: 20)),
      );
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        throw ApiException(
          response.statusCode,
          'invalid_response',
          'The service is temporarily unavailable. Try again shortly.',
        );
      }
      if (response.statusCode >= 400) {
        final error = data['error'] as Map<String, dynamic>? ?? {};
        throw ApiException(
          response.statusCode,
          error['code'] as String? ?? 'request_failed',
          error['message'] as String? ?? 'Please try again.',
          (error['retry_after'] as num?)?.toInt() ?? 0,
        );
      }
      if (!kIsWeb &&
          code != null &&
          path.endsWith('/join') &&
          data['guest_token'] != null) {
        await storage.write(
          key: 'qit.guest.$code',
          value: data['guest_token'] as String,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException(
        0,
        'offline',
        'The connection timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        0,
        'offline',
        'You seem to be offline. We’ll reconnect when you’re back.',
      );
    }
  }

  void dispose() => client.close();
}
