class PackageImageModel {
  final int id;
  final String? imagePath;
  final String? fullUrl;
  final bool isCover;
  final int sortOrder;

  PackageImageModel({
    required this.id,
    this.imagePath,
    this.fullUrl,
    this.isCover = false,
    this.sortOrder = 0,
  });

  factory PackageImageModel.fromJson(Map<String, dynamic> json) {
    return PackageImageModel(
      id: _parseInt(json['id']) ?? 0,
      imagePath: json['image_path'] as String?,
      fullUrl: json['full_url'] as String?,
      isCover: json['is_cover'] == true || json['is_cover'] == 1,
      sortOrder: _parseInt(json['sort_order']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      final d = double.tryParse(value);
      if (d != null) return d.toInt();
    }
    return null;
  }
}

class PackageModel {
  final int id;
  final String name;
  final String description;
  final String terms;
  final int pricePerPerson;
  final int minPerson;
  final String category;
  final String status;
  final String? coverImage;
  final List<PackageImageModel> images;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.terms,
    required this.pricePerPerson,
    required this.minPerson,
    required this.category,
    required this.status,
    this.coverImage,
    this.images = const [],
  });

  // Legacy getters agar widget lama tidak error
  String get title => name;
  String get price => 'Rp $pricePerPerson';
  String get duration => '1 Hari';
  int get maxPeople => minPerson + 5;
  bool get isPublished => status == 'active';

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    return PackageModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
      pricePerPerson: _parseInt(json['price_per_person']) ?? 0,
      minPerson: _parseInt(json['min_person'] ?? json['min_people']) ?? 1,
      category: json['category'] as String? ?? 'kampung_adat',
      status: json['status'] as String? ?? 'active',
      coverImage: json['cover_image'] as String?,
      images: rawImages
          .map((e) => PackageImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      final d = double.tryParse(value);
      if (d != null) return d.toInt();
    }
    return null;
  }

  String get categoryLabel {
    const map = {
      'kampung_adat': 'Budaya',
      'budaya_seni': 'Ritual',
      'edukasi_durian': 'Kuliner',
      'pendakian': 'Alam',
      'trabas': 'Petualangan',
    };
    return map[category] ?? category;
  }
}

// Alias untuk backward compatibility
typedef TravelPackage = PackageModel;
