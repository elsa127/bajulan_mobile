import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/booking_model.dart';

class BookingStatusController extends GetxController {
  final _api = Get.find<ApiService>();

  final codeCtrl = TextEditingController();
  var isLoading = false.obs;
  var booking = Rxn<BookingModel>();
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Jika datang dari payment view dengan booking_code
    final args = Get.arguments as Map<String, dynamic>?;
    final code = args?['booking_code'] as String?;
    if (code != null && code.isNotEmpty) {
      codeCtrl.text = code;
      fetchStatus(code);
    }
  }

  Future<void> fetchStatus(String code) async {
    if (code.trim().isEmpty) {
      error.value = 'Masukkan kode booking terlebih dahulu.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    booking.value = null;
    try {
      final res = await _api.get('/bookings/${code.trim()}');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      booking.value = BookingModel.fromJson(data);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    super.onClose();
  }
}
