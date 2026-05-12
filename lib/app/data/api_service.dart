import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants.dart';

class ApiService extends GetxService {
  final _box = GetStorage();

  String? get _token => _box.read(AppConstants.tokenKey);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── GET ───────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String path) async {
    final res = await http
        .get(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
        .timeout(const Duration(seconds: 30));
    // DEBUG: Disabled to reduce log noise
    // if (path.contains('events') || path.contains('galleries')) {
    //   debugPrint('=== DEBUG [$path] status: ${res.statusCode} ===');
    //   debugPrint(res.body.length > 1000 ? res.body.substring(0, 1000) : res.body);
    // }
    return _handle(res);
  }

  // ─── POST ──────────────────────────────────────────────
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http
        .post(
          Uri.parse('${AppConstants.baseUrl}$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  // ─── PUT ───────────────────────────────────────────────
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http
        .put(
          Uri.parse('${AppConstants.baseUrl}$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  // ─── DELETE ────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(String path) async {
    final res = await http
        .delete(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  // ─── MULTIPART (upload gambar) ─────────────────────────
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}$path'));
    req.headers.addAll({
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    });
    if (fields != null) req.fields.addAll(fields);
    if (files != null) req.files.addAll(files);

    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  // ─── HANDLER ───────────────────────────────────────────
  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response tidak valid dari server.');
    }

    if (res.statusCode == 401) {
      _box.remove(AppConstants.tokenKey);
      _box.remove(AppConstants.userKey);
      Get.offAllNamed('/login');
      throw Exception('Sesi habis, silakan login kembali.');
    }
    if (res.statusCode >= 400) {
      final msg = body['message'] as String? ??
          (body['errors'] != null ? _flattenErrors(body['errors']) : null) ??
          'Terjadi kesalahan server (${res.statusCode}).';
      throw Exception(msg);
    }
    return body;
  }

  String _flattenErrors(dynamic errors) {
    if (errors is Map) {
      return errors.values
          .map((v) => v is List ? v.join(', ') : v.toString())
          .join('\n');
    }
    return errors.toString();
  }
}
