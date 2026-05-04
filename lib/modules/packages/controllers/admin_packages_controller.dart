import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/package_model.dart';

class AdminPackagesController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var packages = <PackageModel>[].obs;
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
      final res = await _api.get('/admin/packages');
      final list = _extractList(res);
      packages.value = list.map((e) => PackageModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete('/admin/packages/$id');
      packages.removeWhere((p) => p.id == id);
      Get.snackbar('Sukses', 'Paket berhasil dihapus.',
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

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> res) {
    final raw = res['data'] ?? res['packages'] ?? [];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
