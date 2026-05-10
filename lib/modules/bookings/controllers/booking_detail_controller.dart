import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/booking_model.dart';

class BookingDetailController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var booking = Rxn<BookingModel>();
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments?['id'] as int?;
    if (id != null) fetch(id);
  }

  Future<void> fetch(int id) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/bookings/$id');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      booking.value = BookingModel.fromJson(data);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
