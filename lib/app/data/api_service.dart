import 'dart:convert';
import 'dart:io';
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
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ─── POST ──────────────────────────────────────────────
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ─── PUT ───────────────────────────────────────────────
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ─── DELETE ────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ─── MULTIPART (upload gambar) ─────────────────────────
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    try {
      final req = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.baseUrl}$path'));
      req.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
      if (fields != null) req.fields.addAll(fields);
      if (files != null) req.files.addAll(files);

      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      return _handle(res);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ─── HANDLER ───────────────────────────────────────────
  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Server mengirim respons yang tidak valid. Coba lagi nanti.');
    }

    if (res.statusCode == 401) {
      _box.remove(AppConstants.tokenKey);
      _box.remove(AppConstants.userKey);
      Get.offAllNamed('/login');
      throw Exception('Sesi login habis. Silakan login kembali.');
    }
    if (res.statusCode == 403) {
      throw Exception('Anda tidak memiliki akses untuk melakukan tindakan ini.');
    }
    if (res.statusCode == 404) {
      throw Exception('Data yang dicari tidak ditemukan.');
    }
    if (res.statusCode == 422) {
      final msg = body['message'] as String? ??
          (body['errors'] != null ? _flattenErrors(body['errors']) : null) ??
          'Data yang dimasukkan tidak valid.';
      throw Exception(msg);
    }
    if (res.statusCode == 500) {
      throw Exception('Terjadi kesalahan pada server. Coba lagi beberapa saat.');
    }
    if (res.statusCode >= 400) {
      final msg = body['message'] as String? ??
          (body['errors'] != null ? _flattenErrors(body['errors']) : null) ??
          'Terjadi kesalahan (kode ${res.statusCode}). Coba lagi.';
      throw Exception(msg);
    }
    return body;
  }

  // ─── PESAN ERROR YANG RAMAH ────────────────────────────
  String _friendlyError(dynamic e) {
    final str = e.toString();

    // Tidak ada koneksi internet / DNS gagal
    if (str.contains('SocketException') ||
        str.contains('SocketFailed') ||
        str.contains('Failed host lookup') ||
        str.contains('No address associated') ||
        str.contains('Network is unreachable') ||
        str.contains('Connection refused') ||
        str.contains('errno = 7') ||
        str.contains('errno = 111')) {
      return 'Tidak ada koneksi internet.\nPastikan WiFi atau data seluler aktif, lalu coba lagi.';
    }

    // Timeout
    if (str.contains('TimeoutException') ||
        str.contains('timed out') ||
        str.contains('Connection timed')) {
      return 'Koneksi terlalu lambat atau server tidak merespons.\nCoba lagi dalam beberapa saat.';
    }

    // SSL/TLS error
    if (str.contains('HandshakeException') ||
        str.contains('CERTIFICATE') ||
        str.contains('tlsv1')) {
      return 'Koneksi tidak aman. Periksa pengaturan jaringan Anda.';
    }

    // Sudah pesan yang ramah (dari _handle)
    if (e is Exception) {
      final msg = str.replaceFirst('Exception: ', '');
      if (!msg.contains('ClientException') &&
          !msg.contains('SocketException') &&
          !msg.contains('TimeoutException')) {
        return msg;
      }
    }

    return 'Tidak dapat terhubung ke server.\nPeriksa koneksi internet dan coba lagi.';
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
