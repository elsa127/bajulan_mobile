import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/booking_model.dart';

class BookingController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var bookings = <BookingModel>[].obs;
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
      final res = await _api.get('/admin/bookings');
      final raw = res['data'] ?? res['bookings'] ?? [];
      final list = raw is List ? raw.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      bookings.value = list.map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
