import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/dashboard_model.dart';

class DashboardController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var dashboard = Rxn<DashboardModel>();
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/dashboard');
      dashboard.value = DashboardModel.fromJson(res);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
