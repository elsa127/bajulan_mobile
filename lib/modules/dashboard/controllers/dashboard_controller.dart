import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/dashboard_model.dart';
import '../../notifications/controllers/notification_controller.dart';

class DashboardController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var dashboard = Rxn<DashboardModel>();
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
    // Refresh notifikasi juga
    _refreshNotifications();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/dashboard');
      dashboard.value = DashboardModel.fromJson(res);
      // Refresh notifikasi setiap kali fetch dashboard
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
