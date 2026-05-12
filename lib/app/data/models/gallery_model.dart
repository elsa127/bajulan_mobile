import 'package:flutter/foundation.dart';

const _baseStorageUrl = 'https://kampungadatbajulan.pbltifnganjuk.com/storage/';
const _baseUrl = 'https://kampungadatbajulan.pbltifnganjuk.com';

class GalleryModel {
  final int id;
  final String imageUrl;
  final String title;
  final String? caption;
  final String? category;
  final bool isFeatured;
  final int? sortOrder;

  GalleryModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.caption,
    this.category,
    this.isFeatured = false,
    this.sortOrder,
  });

  String get categoryLabel {
    const map = {
      'kampung': 'Kampung Adat',
      'budaya': 'Budaya',
      'alam': 'Alam',
      'kuliner': 'Kuliner',
      'event': 'Event',
      'lainnya': 'Lainnya',
    };
    return map[category] ?? category ?? '';
  }

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    // Debug: Disabled to reduce log noise
    // debugPrint('[GalleryModel] Available keys: ${json.keys.toList()}');
    
    // Coba berbagai kemungkinan field name dari backend
    final rawUrl = json['full_url'] as String? ??
        json['image_url'] as String? ??
        json['image_path'] as String? ??
        json['url'] as String? ??
        json['path'] as String? ??
        '';

    // debugPrint('[GalleryModel] Raw URL from backend: "$rawUrl"');
    
    // Resolve URL
    final resolved = _resolveImageUrl(rawUrl);
    // debugPrint('[GalleryModel] Resolved URL: "$resolved"');

    return GalleryModel(
      id: _parseInt(json['id']) ?? 0,
      imageUrl: resolved,
      title: json['title'] as String? ?? '',
      caption: json['caption'] as String?,
      category: json['category'] as String?,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      sortOrder: _parseInt(json['sort_order']),
    );
  }

  /// Resolve image URL dari berbagai format path
  static String _resolveImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) {
      // debugPrint('[GalleryModel] ⚠️ Empty or null path');
      return '';
    }
    
    // Jika sudah full URL, return as-is
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      // debugPrint('[GalleryModel] ✓ Full URL detected');
      return rawPath;
    }
    
    // Bersihkan leading slash
    final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
    
    // Deteksi folder dari path dan build URL
    String resolvedUrl;
    if (cleanPath.startsWith('storage/')) {
      // Path sudah include "storage/"
      resolvedUrl = '$_baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('uploads/')) {
      // Path sudah include "uploads/"
      resolvedUrl = '$_baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('galleries/')) {
      // GANTI: Coba uploads dulu, karena storage 404
      resolvedUrl = '$_baseUrl/uploads/$cleanPath';
      // debugPrint('[GalleryModel] 🔄 Trying /uploads/ instead of /storage/');
    } else {
      // Default: coba uploads dulu
      resolvedUrl = '$_baseUrl/uploads/$cleanPath';
    }
    
    // debugPrint('[GalleryModel] "$rawPath" → "$resolvedUrl"');
    return resolvedUrl;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
