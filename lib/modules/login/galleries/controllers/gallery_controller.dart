import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/data/api_service.dart';
import '../../../../app/data/models/gallery_model.dart';

class GalleryController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var galleries = <GalleryModel>[].obs;
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
      final res = await _api.get('/admin/galleries');
      final raw = res['data'] ?? res['galleries'] ?? [];
      final list = raw is List ? raw.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      galleries.value = list.map((e) => GalleryModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete('/admin/galleries/$id');
      galleries.removeWhere((g) => g.id == id);
      Get.snackbar('Sukses', 'Foto berhasil dihapus.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
