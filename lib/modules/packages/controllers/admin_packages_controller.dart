import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import 'package:bajulan_mobile/app/data/models/package_model.dart';


class AdminPackagesController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var packages = <PackageModel>[].obs;
  var error = ''.obs;
  var selectedFilter = 'all'.obs;
  var searchQuery = ''.obs;

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

  List<PackageModel> get filteredPackages {
    var list = packages.toList();

// SEARCH
    if (searchQuery.value.isNotEmpty) {
      list = list.where((p) =>
          p.name.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

// FILTER
    if (selectedFilter.value == 'cultural') {
      list = list.where((p) => p.category == 'budaya_seni').toList();
    } else if (selectedFilter.value == 'nature') {
      list = list.where((p) => p.category == 'pendakian').toList();
    } else if (selectedFilter.value == 'adventure') {
      list = list.where((p) => p.category == 'trabas').toList();
    }

    return list;
  }
}
