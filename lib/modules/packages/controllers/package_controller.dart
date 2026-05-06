import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PackageController extends GetxController {
  final _api = Get.find<ApiService>();

  // --- FORM CONTROLLER ---
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final minPeopleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final termsCtrl = TextEditingController();

  // --- STATE ---
  var selectedCategory = 'kampung_adat'.obs;
  var includeLunch = false.obs;
  var includeGuide = false.obs;
  var isLoading = false.obs;
  var selectedImage = Rx<File?>(null);

  // --- CATEGORY LIST ---
  final categories = [
    {'key': 'kampung_adat', 'label': 'Kampung Adat'},
    {'key': 'budaya_seni', 'label': 'Budaya & Seni'},
    {'key': 'edukasi_durian', 'label': 'Edukasi Durian'},
    {'key': 'pendakian', 'label': 'Pendakian'},
    {'key': 'trabas', 'label': 'Trabas'},
  ];

  // --- PICK IMAGE ---
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  // --- SAVE DATA ---
  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Oops!',
        'Nama paket harus diisi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      List<http.MultipartFile> files = [];

      if (selectedImage.value != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'cover_image',
            selectedImage.value!.path,
          ),
        );
      }

      await _api.postMultipart(
        '/admin/packages',
        fields: {
          'name': nameCtrl.text.trim(),
          'description': descCtrl.text.trim(),
          'terms': termsCtrl.text.trim(),
          'price_per_person': (int.tryParse(
              priceCtrl.text.replaceAll('.', '')) ??
              0)
              .toString(),
          'min_person':
          (int.tryParse(minPeopleCtrl.text) ?? 1).toString(),
          'category': selectedCategory.value,
        },
        files: files,
      );

      Get.snackbar(
        'Sukses',
        'Paket berhasil ditambahkan!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 1), () {
        clearForm();
        Get.back();
      });
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- RESET FORM ---
  void clearForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    minPeopleCtrl.clear();
    descCtrl.clear();
    termsCtrl.clear();
    selectedImage.value = null;
    selectedCategory.value = 'kampung_adat';
    includeLunch.value = false;
    includeGuide.value = false;
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