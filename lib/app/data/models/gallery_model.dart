const _baseStorageUrl = 'https://kampungadatbajulan.pbltifnganjuk.com/storage/';

class GalleryModel {
  final int id;
  final String imageUrl;
  final String? caption;
  final String? category;
  final int? sortOrder;

  GalleryModel({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.category,
    this.sortOrder,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    // Coba semua kemungkinan field name dari backend Laravel
    final rawUrl = json['full_url'] as String? ??
        json['image_url'] as String? ??
        json['url'] as String? ??
        json['image_path'] as String? ??
        json['file_path'] as String? ??
        json['path'] as String? ??
        '';

    final resolvedUrl = _resolveUrl(rawUrl);

    return GalleryModel(
      id: _parseInt(json['id']) ?? 0,
      imageUrl: resolvedUrl,
      caption: json['caption'] as String? ?? json['title'] as String?,
      category: json['category'] as String?,
      sortOrder: _parseInt(json['sort_order']),
    );
  }

  /// Pastikan URL selalu absolute — pakai /uploads/ bukan /storage/
  static String _resolveUrl(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    final clean = raw.startsWith('/') ? raw.substring(1) : raw;
    return 'https://kampungadatbajulan.pbltifnganjuk.com/uploads/$clean';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
