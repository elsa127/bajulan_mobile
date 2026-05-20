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
    // Coba berbagai kemungkinan nama field dari backend
    final rawUrl = json['full_url'] as String? ??
        json['image_url'] as String? ??
        json['image_path'] as String? ??
        json['url'] as String? ??
        json['path'] as String? ??
        '';

    final resolved = _resolveImageUrl(rawUrl);

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

  // Ubah path relatif menjadi URL lengkap
  static String _resolveImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return '';

    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }

    final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;

    if (cleanPath.startsWith('storage/')) {
      return '$_baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('uploads/')) {
      return '$_baseUrl/$cleanPath';
    } else if (cleanPath.startsWith('galleries/')) {
      // Gunakan /uploads/ — /storage/ mengembalikan 404 untuk path ini
      return '$_baseUrl/uploads/$cleanPath';
    } else {
      return '$_baseUrl/uploads/$cleanPath';
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
