import 'package:flutter/foundation.dart';

/// Helper untuk resolve URL gambar dari berbagai sumber
class ImageUrlHelper {
  // Base URLs yang mungkin digunakan backend
  static const String baseUrl = 'https://kampungadatbajulan.pbltifnganjuk.com';
  static const String storageUrl = '$baseUrl/storage';
  static const String uploadsUrl = '$baseUrl/uploads';
  
  /// Resolve URL gambar dengan berbagai fallback
  static String resolve(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) {
      // debugPrint('[ImageUrlHelper] ⚠️ Empty or null path');
      return '';
    }
    
    // Jika sudah full URL, return as-is
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      // debugPrint('[ImageUrlHelper] ✓ Full URL: $rawPath');
      return rawPath;
    }
    
    // Bersihkan leading slash
    final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
    
    // Deteksi folder dari path
    String resolvedUrl;
    if (cleanPath.startsWith('storage/')) {
      // Path sudah include "storage/"
      resolvedUrl = '$baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('uploads/')) {
      // Path sudah include "uploads/"
      resolvedUrl = '$baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('galleries/')) {
      // Path galleries biasanya di storage
      resolvedUrl = '$storageUrl/$cleanPath';
    } else {
      // Default: assume di storage
      resolvedUrl = '$storageUrl/$cleanPath';
    }
    
    // debugPrint('[ImageUrlHelper] "$rawPath" → "$resolvedUrl"');
    return resolvedUrl;
  }
  
  /// Resolve dengan multiple fallback URLs
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
  
  /// Test URL (untuk debugging)
  static void testUrl(String url) {
    // debugPrint('═══════════════════════════════════════════');
    // debugPrint('[ImageUrlHelper] Testing URL: $url');
    // debugPrint('[ImageUrlHelper] Fallbacks:');
    final fallbacks = resolveFallbacks(url);
    for (var i = 0; i < fallbacks.length; i++) {
      // debugPrint('  ${i + 1}. ${fallbacks[i]}');
    }
    // debugPrint('═══════════════════════════════════════════');
  }
}
