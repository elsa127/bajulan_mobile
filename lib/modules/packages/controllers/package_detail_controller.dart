import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import 'package:bajulan_mobile/app/data/models/package_model.dart';

class PackageDetailController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var package = Rxn<PackageModel>();
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'];
    if (id != null) fetchDetail(int.parse(id));
  }

  Future<void> fetchDetail(int id) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/packages/$id');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      package.value = PackageModel.fromJson(data);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
