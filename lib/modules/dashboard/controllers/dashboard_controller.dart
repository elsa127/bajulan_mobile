import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/dashboard_model.dart';
import '../../../app/data/models/event_model.dart';
import '../../notifications/controllers/notification_controller.dart';

class DashboardController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var dashboard = Rxn<DashboardModel>();
  var error = ''.obs;
  var ongoingEvents = <EventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
    _cleanPendingBookings();
    _refreshNotifications();
  }

  // Picu auto-cancel booking kedaluwarsa di backend — GET /admin/artisan/clean-pending-bookings
  Future<void> _cleanPendingBookings() async {
    try {
      await _api.get('/admin/artisan/clean-pending-bookings');
    } catch (_) {
      // Gagal diam-diam, tidak perlu tampilkan error
    }
  }

  // [BACA] Ambil statistik dashboard dan daftar event secara paralel
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        _api.get('/admin/dashboard'),
        _api.get('/admin/events'),
      ]);

      dashboard.value = DashboardModel.fromJson(results[0]);

      // Tampilkan hanya event yang sedang berlangsung atau akan datang
      final raw = results[1]['data'] ?? [];
      final list = raw is List ? raw.cast<Map<String, dynamic>>() : [];
      ongoingEvents.value = list
          .map((e) => EventModel.fromJson(e))
          .where((e) => e.status == 'ongoing' || e.status == 'upcoming')
          .toList();

      _refreshNotifications();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshNotifications() {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetch();
    }
  }
}
