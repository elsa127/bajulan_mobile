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
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
      pricePerPerson: _parseInt(json['price_per_person']) ?? 0,
      minPerson: _parseInt(json['min_person']) ?? 1,
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      coverImage: json['cover_image'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  String get categoryLabel {
    const map = {
      'kampung_adat': 'Kampung Adat',
      'budaya_seni': 'Budaya & Seni',
      'edukasi_durian': 'Edukasi Durian',
      'pendakian': 'Pendakian',
      'trabas': 'Trabas',
    };
    return map[category] ?? category;
  }
}
