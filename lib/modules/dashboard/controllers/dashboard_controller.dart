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
    _refreshNotifications();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      // Fetch dashboard dan event berlangsung secara paralel
      final results = await Future.wait([
        _api.get('/admin/dashboard'),
        _api.get('/admin/events'),
      ]);

      dashboard.value = DashboardModel.fromJson(results[0]);

      // Filter event yang sedang berlangsung atau upcoming
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
