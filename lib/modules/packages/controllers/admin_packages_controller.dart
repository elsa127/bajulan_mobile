import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../app/data/api_service.dart';
import '../../../app/data/models/package_model.dart';

class AdminPackagesController extends GetxController {
  final _api = Get.find<ApiService>();
  final _picker = ImagePicker();

  var isLoading = true.obs;
  var packages = <PackageModel>[].obs;
  var error = ''.obs;
  var selectedFilter = 'all'.obs;
  var searchQuery = ''.obs;

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final minPeopleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final termsCtrl = TextEditingController();
  var selectedCategory = 'kampung_adat'.obs;
  var selectedStatus = 'active'.obs;
  var coverImageFile = Rxn<XFile>();
  var isSubmitting = false.obs;

  final categories = [
    {'key': 'kampung_adat', 'label': 'Budaya'},
    {'key': 'pendakian', 'label': 'Alam'},
    {'key': 'budaya_seni', 'label': 'Ritual'},
    {'key': 'edukasi_durian', 'label': 'Kuliner'},
    {'key': 'trabas', 'label': 'Petualangan'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  // [BACA] Ambil semua paket — GET /admin/packages
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

  // Isi form dengan data paket yang akan diedit
  void fillFormForEdit(PackageModel pkg) {
    nameCtrl.text = pkg.name;
    priceCtrl.text = pkg.pricePerPerson.toString();
    minPeopleCtrl.text = pkg.minPerson.toString();
    descCtrl.text = pkg.description;
    termsCtrl.text = pkg.terms;
    selectedCategory.value = pkg.category;
    selectedStatus.value = pkg.status;
    coverImageFile.value = null;
  }

  Future<void> pickCoverImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null) coverImageFile.value = picked;
  }

  // [UBAH] Perbarui paket — POST /admin/packages/:id dengan _method=PUT (Laravel method spoofing)
  Future<void> updatePackage(int id) async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Oops!', 'Nama paket harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final fields = {
        '_method': 'PUT',
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'terms': termsCtrl.text.trim(),
        'price_per_person':
            (int.tryParse(priceCtrl.text.replaceAll('.', '')) ?? 0).toString(),
        'min_person': (int.tryParse(minPeopleCtrl.text) ?? 1).toString(),
        'category': selectedCategory.value,
        'status': selectedStatus.value,
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

      await _api.postMultipart('/admin/packages/$id',
          fields: fields, files: files.isEmpty ? null : files);

      Get.back();
      fetch();
      Get.snackbar('Sukses', 'Paket berhasil diperbarui.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  // [HAPUS] Hapus paket — DELETE /admin/packages/:id
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

  // Hasil filter berdasarkan pencarian dan kategori
  List<PackageModel> get filteredPackages {
    var list = packages.toList();
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    if (selectedFilter.value != 'all') {
      list = list.where((p) => p.category == selectedFilter.value).toList();
    }
    return list;
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> res) {
    final raw = res['data'] ?? res['packages'] ?? [];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  void onClose() {
    // Tidak dispose controller — fenix: true bisa recreate controller ini
    super.onClose();
  }
}
