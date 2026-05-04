class GalleryModel {
  final int id;
  final String imageUrl;
  final String? caption;

  GalleryModel({required this.id, required this.imageUrl, this.caption});

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: _parseInt(json['id']) ?? 0,
      imageUrl: json['image_url'] as String? ?? json['url'] as String? ?? '',
      caption: json['caption'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
