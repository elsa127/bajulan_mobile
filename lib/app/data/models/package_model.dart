enum PackageStatus { published, unpublished }

class PackageModel {
  final int id;
  final String name;
  final String description;
  final String terms;
  final int pricePerPerson;
  final int minPerson;
  final String category;
  final String? image;
  final PackageStatus status;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.terms,
    required this.pricePerPerson,
    required this.minPerson,
    required this.category,
    this.image,
    this.status = PackageStatus.published,
  });

  // Legacy fields for some widgets that might use TravelPackage names
  String get title => name;
  String get price => 'Rp $pricePerPerson';
  String get duration => '1 Hari'; // Default duration
  int get maxPeople => minPerson + 5; // Example logic for max people

  String get coverImage => image ?? 'https://picsum.photos/seed/$id/800/450';

  String get categoryLabel {
    switch (category) {
      case 'kampung_adat': return 'Kampung Adat';
      case 'budaya_seni': return 'Budaya & Seni';
      case 'edukasi_durian': return 'Edukasi Durian';
      case 'pendakian': return 'Pendakian';
      case 'trabas': return 'Trabas';
      default: return 'Lainnya';
    }
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    int parseSafeInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return PackageModel(
      id: parseSafeInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      terms: json['terms']?.toString() ?? '',
      pricePerPerson: parseSafeInt(json['price_per_person']),
      minPerson: parseSafeInt(json['min_person'] ?? json['min_people']),
      category: json['category']?.toString() ?? 'kampung_adat',
      image: json['image']?.toString(),
      status: json['is_published'] == false ? PackageStatus.unpublished : PackageStatus.published,
    );
  }
}

// Keep TravelPackage as an alias if needed
typedef TravelPackage = PackageModel;
