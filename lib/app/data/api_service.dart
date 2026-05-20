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

  // Header dengan token autentikasi
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Ambil data dari API
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handle(res, path);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // Kirim data ke API
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res, path);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // Perbarui data di API
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res, path);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // Hapus data dari API
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handle(res, path);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // Upload file (multipart)
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
      return _handle(res, path);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // Proses respons dari server
  Map<String, dynamic> _handle(http.Response res, String path) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Server mengirim respons yang tidak valid. Coba lagi nanti.');
    }

    if (res.statusCode == 401) {
      // Jangan auto-logout saat proses login
      if (path.contains('/auth/login')) {
        throw Exception('Email atau password salah. Silakan coba lagi.');
      }
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

  // pesan eror
  String _friendlyError(dynamic e) {
    final str = e.toString();

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

    if (str.contains('TimeoutException') ||
        str.contains('timed out') ||
        str.contains('Connection timed')) {
      return 'Koneksi terlalu lambat atau server tidak merespons.\nCoba lagi dalam beberapa saat.';
    }

    if (str.contains('HandshakeException') ||
        str.contains('CERTIFICATE') ||
        str.contains('tlsv1')) {
      return 'Koneksi tidak aman. Periksa pengaturan jaringan Anda.';
    }

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

  // Gabungkan semua pesan error validasi menjadi satu string
  String _flattenErrors(dynamic errors) {
    if (errors is Map) {
      return errors.values
          .map((v) => v is List ? v.join(', ') : v.toString())
          .join('\n');
    }
    return errors.toString();
  }
}
