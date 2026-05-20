const _baseStorageUrl = 'https://kampungadatbajulan.pbltifnganjuk.com/storage/';

class EventModel {
  final int id;
  final String name;
  final String description;
  final String eventDate;
  final String? startTime;
  final String? endTime;
  final String location;
  final String status;
  final String? imagePath;
  final String? fullUrl;
  final int? packageId;
  final Map<String, dynamic>? package;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.eventDate,
    this.startTime,
    this.endTime,
    required this.location,
    required this.status,
    this.imagePath,
    this.fullUrl,
    this.packageId,
    this.package,
  });

  // Prioritaskan full_url, fallback ke imagePath
  String? get imageUrl {
    if (fullUrl != null && fullUrl!.isNotEmpty) return fullUrl;
    if (imagePath == null || imagePath!.isEmpty) return null;
    if (imagePath!.startsWith('http')) return imagePath;
    final clean = imagePath!.startsWith('/') ? imagePath!.substring(1) : imagePath!;
    return 'https://kampungadatbajulan.pbltifnganjuk.com/uploads/$clean';
  }

  String get packageName =>
      package?['name'] as String? ?? '';

  String get statusLabel {
    switch (status) {
      case 'upcoming': return 'Upcoming';
      case 'ongoing': return 'Ongoing';
      case 'done': return 'Done';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawImagePath = json['image_path'] as String?;
    final rawFullUrl = json['full_url'] as String?;

    return EventModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? 'upcoming',
      imagePath: rawImagePath,
      fullUrl: rawFullUrl,
      packageId: _parseInt(json['package_id']),
      package: json['package'] as Map<String, dynamic>?,
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
