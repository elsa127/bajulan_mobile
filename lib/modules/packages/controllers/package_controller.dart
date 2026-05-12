import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../app/data/api_service.dart';

class PackageController extends GetxController {
  final _api = Get.find<ApiService>();
  final _picker = ImagePicker();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final minPeopleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final termsCtrl = TextEditingController();

  var selectedCategory = 'kampung_adat'.obs;
  var includeLunch = false.obs;
  var includeGuide = false.obs;
  var isLoading = false.obs;
  var coverImageFile = Rxn<XFile>(); // XFile support web & mobile

  final categories = [
    {'key': 'kampung_adat', 'label': 'Budaya'},
    {'key': 'pendakian', 'label': 'Alam'},
    {'key': 'budaya_seni', 'label': 'Ritual'},
    {'key': 'edukasi_durian', 'label': 'Kuliner'},
    {'key': 'trabas', 'label': 'Petualangan'},
  ];

  // Alias untuk backward compat dengan add_package_view lama
  XFile? get selectedImage => coverImageFile.value;

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null) coverImageFile.value = picked;
  }

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
      final fields = {
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'terms': termsCtrl.text.trim(),
        'price_per_person':
            (int.tryParse(priceCtrl.text.replaceAll('.', '')) ?? 0).toString(),
        'min_person': (int.tryParse(minPeopleCtrl.text) ?? 1).toString(),
        'category': selectedCategory.value,
        'status': 'active',
      };

      final files = <http.MultipartFile>[];
      if (coverImageFile.value != null) {
        final bytes = await coverImageFile.value!.readAsBytes();
        files.add(http.MultipartFile.fromBytes(
          'cover_image',
          bytes,
          filename: coverImageFile.value!.name,
        ));
      }

      await _api.postMultipart('/admin/packages',
          fields: fields, files: files.isEmpty ? null : files);

      Get.snackbar('Sukses', 'Paket berhasil ditambahkan!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      Future.delayed(const Duration(seconds: 1), () {
        clearForm();
        Get.back();
      });
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    minPeopleCtrl.clear();
    descCtrl.clear();
    termsCtrl.clear();
    coverImageFile.value = null;
    selectedCategory.value = 'kampung_adat';
    includeLunch.value = false;
    includeGuide.value = false;
  }

  @override
  void onClose() {
    // TextEditingControllers are NOT disposed here because this controller
    // uses fenix: true — GetX may recreate it, and disposing here causes
    // "used after being disposed" errors on re-entry.
    super.onClose();
  }
}
