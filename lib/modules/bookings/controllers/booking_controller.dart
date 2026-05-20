import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/booking_model.dart';

class BookingController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var bookings = <BookingModel>[].obs;
  var error = ''.obs;
  var selectedFilter = 'semua'.obs;
  var selectedMonth = Rxn<DateTime>();

  final filters = ['semua', 'paid', 'pending', 'cancelled'];

  List<BookingModel> get filtered {
    var list = bookings.toList();

    if (selectedFilter.value != 'semua') {
      list = list
          .where((b) => b.status.toLowerCase() == selectedFilter.value)
          .toList();
    }

    if (selectedMonth.value != null) {
      final m = selectedMonth.value!;
      list = list.where((b) {
        if (b.createdAt == null) return false;
        try {
          final d = DateTime.parse(b.createdAt!);
          return d.year == m.year && d.month == m.month;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    return list;
  }

  // Total pendapatan dari hasil filter (hanya status paid/confirmed)
  int get filteredRevenue => filtered
      .where((b) => b.status == 'paid' || b.status == 'confirmed')
      .fold(0, (sum, b) => sum + b.totalPrice);

  // Daftar bulan yang tersedia berdasarkan data booking
  List<DateTime> get availableMonths {
    final months = <DateTime>{};
    for (final b in bookings) {
      if (b.createdAt != null) {
        try {
          final d = DateTime.parse(b.createdAt!);
          months.add(DateTime(d.year, d.month));
        } catch (_) {}
      }
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  void selectMonth(DateTime? month) {
    selectedMonth.value = month;
  }

  @override
  void onInit() {
    super.onInit();
    _cleanPendingBookings();
    fetch();
  }

  // Picu auto-cancel booking kedaluwarsa di backend — GET /admin/artisan/clean-pending-bookings
  Future<void> _cleanPendingBookings() async {
    try {
      await _api.get('/admin/artisan/clean-pending-bookings');
    } catch (_) {
      // Gagal diam-diam, tidak perlu tampilkan error
    }
  }

  // [BACA] Ambil semua data booking — GET /admin/bookings
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/bookings');
      final raw = res['data'] ?? res['bookings'] ?? [];
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      bookings.value = list.map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
