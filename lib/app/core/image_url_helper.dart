import 'package:flutter/foundation.dart';

/// Helper untuk mengubah path gambar dari backend menjadi URL lengkap
class ImageUrlHelper {
  static const String baseUrl = 'https://kampungadatbajulan.pbltifnganjuk.com';
  static const String storageUrl = '$baseUrl/storage';
  static const String uploadsUrl = '$baseUrl/uploads';

  // Ubah path relatif menjadi URL lengkap
  static String resolve(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return '';

    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }

    final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;

    if (cleanPath.startsWith('storage/')) {
      return '$baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('uploads/')) {
      return '$baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('galleries/')) {
      return '$storageUrl/$cleanPath';
    } else {
      return '$storageUrl/$cleanPath';
    }
  }

  // Kembalikan beberapa kandidat URL sebagai fallback pemuatan gambar
  static List<String> resolveFallbacks(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return [];
    if (rawPath.startsWith('http')) return [rawPath];

    final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;

    return [
      '$storageUrl/$cleanPath',
      '$uploadsUrl/$cleanPath',
      '$baseUrl/$cleanPath',
    ];
  }

  static void testUrl(String url) {
    resolveFallbacks(url);
  }
}
