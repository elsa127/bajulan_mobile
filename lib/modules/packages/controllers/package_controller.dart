import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';

class PackageController extends GetxController {
  final _api = Get.find<ApiService>();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final minPeopleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final termsCtrl = TextEditingController();

  var selectedCategory = 'kampung_adat'.obs;
  var includeLunch = false.obs;
  var includeGuide = false.obs;
  var isLoading = false.obs;

  final categories = [
    {'key': 'kampung_adat', 'label': 'Kampung Adat'},
    {'key': 'budaya_seni', 'label': 'Budaya & Seni'},
    {'key': 'edukasi_durian', 'label': 'Edukasi Durian'},
    {'key': 'pendakian', 'label': 'Pendakian'},
    {'key': 'trabas', 'label': 'Trabas'},
  ];

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Oops!', 'Nama paket harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await _api.post('/admin/packages', {
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'terms': termsCtrl.text.trim(),
        'price_per_person': int.tryParse(priceCtrl.text.replaceAll('.', '')) ?? 0,
        'min_person': int.tryParse(minPeopleCtrl.text) ?? 1,
        'category': selectedCategory.value,
      });

      Get.snackbar('Sukses', 'Paket berhasil ditambahkan!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      Future.delayed(const Duration(seconds: 1), () => Get.back());
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    minPeopleCtrl.dispose();
    descCtrl.dispose();
    termsCtrl.dispose();
    super.onClose();
  }
}
