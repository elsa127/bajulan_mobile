class BookingModel {
  final int? id;
  final String code;
  final String guestName;
  final String guestPhone;
  final String? guestEmail;
  final String visitDate;
  final int totalPerson;
  final String? notes;
  final String status;
  final int totalPrice;
  final String? snapToken;
  final PackageSummary? package;

  BookingModel({
    this.id,
    required this.code,
    required this.guestName,
    required this.guestPhone,
    this.guestEmail,
    required this.visitDate,
    required this.totalPerson,
    this.notes,
    required this.status,
    required this.totalPrice,
    this.snapToken,
    this.package,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _parseInt(json['id']),
      code: json['booking_code'] as String? ?? json['code'] as String? ?? '-',
      guestName: json['guest_name'] as String? ?? '-',
      guestPhone: json['guest_phone'] as String? ?? '-',
      guestEmail: json['guest_email'] as String?,
      visitDate: json['visit_date'] as String? ?? '',
      totalPerson: _parseInt(json['total_person']) ?? 0,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      totalPrice: _parseInt(json['total_price']) ?? 0,
      snapToken: json['snap_token'] as String?,
      package: json['package'] != null
          ? PackageSummary.fromJson(json['package'] as Map<String, dynamic>)
          : null,
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

class PackageSummary {
  final int id;
  final String name;
  final String? coverImage;

  PackageSummary({required this.id, required this.name, this.coverImage});

  factory PackageSummary.fromJson(Map<String, dynamic> json) {
    return PackageSummary(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
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
}
