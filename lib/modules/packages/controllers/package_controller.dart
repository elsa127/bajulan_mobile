import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackageController extends GetxController {
  // Input Controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final minPeopleController = TextEditingController();
  final descController = TextEditingController();

  // Toggles (Bento details)
  var includeLunch = true.obs;
  var includeGuide = true.obs;

  void savePackage() {
    // Validasi sederhana
    if (nameController.text.isEmpty) {
      Get.snackbar('Opps!', 'Nama paket harus diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white
      );
      return;
    }

    // Simulasi simpan data
    print("Menyimpan Paket: ${nameController.text}");
    print("Harga: ${priceController.text}");
    print("Makan Siang: ${includeLunch.value}");

    Get.snackbar('Sukses', 'Paket berhasil ditambahkan!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white
    );

    // Kembali ke halaman sebelumnya setelah 1 detik
    Future.delayed(const Duration(seconds: 1), () => Get.back());
  }

  @override
  void onClose() {
    // Bersihkan memori saat controller tidak dipakai
    nameController.dispose();
    priceController.dispose();
    minPeopleController.dispose();
    descController.dispose();
    super.onClose();
  }
}