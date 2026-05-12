class DashboardModel {
  final int totalBookingHariIni;
  final int totalPendapatanBulanIni;
  final int jumlahPaketAktif;
  final List<Map<String, dynamic>> bookingTerbaru;

  DashboardModel({
    required this.totalBookingHariIni,
    required this.totalPendapatanBulanIni,
    required this.jumlahPaketAktif,
    required this.bookingTerbaru,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return DashboardModel(
      totalBookingHariIni: _parseInt(data['total_booking_hari_ini']) ?? 0,
      totalPendapatanBulanIni:
          _parseInt(data['total_pendapatan_bulan_ini']) ?? 0,
      jumlahPaketAktif: _parseInt(data['jumlah_paket_aktif']) ?? 0,
      bookingTerbaru: (data['booking_terbaru'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  /// Handles int, double, num, and decimal strings like "50000.00"
  /// from Laravel decimal/numeric DB columns.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt();
    return null;
  }
}
