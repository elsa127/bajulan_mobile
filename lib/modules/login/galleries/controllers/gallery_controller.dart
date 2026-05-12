import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../app/data/api_service.dart';
import '../../../../app/data/models/gallery_model.dart';

class GalleryController extends GetxController {
  final _api = Get.find<ApiService>();

  // ── State list ─────────────────────────────────────────
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var galleries = <GalleryModel>[].obs;
  var error = ''.obs;

  // ── Progress upload batch ──────────────────────────────
  var uploadProgress = 0.obs;   // berapa yang sudah selesai
  var uploadTotal = 0.obs;      // total yang akan diupload

  // ── Filter ─────────────────────────────────────────────
  var selectedFilter = 'semua'.obs;

  List<GalleryModel> get filtered {
    if (selectedFilter.value == 'semua') return galleries;
    return galleries.where((g) => g.category == selectedFilter.value).toList();
  }

  // ── Form fields ────────────────────────────────────────
  final titleCtrl = TextEditingController();
  final captionCtrl = TextEditingController();
  var selectedCategory = 'kampung'.obs;
  var isFeatured = false.obs;

  // Multi-select: list XFile
  var selectedImages = <XFile>[].obs;

  // ── Edit mode ──────────────────────────────────────────
  var isEditMode = false.obs;
  var editingGalleryId = Rxn<int>();

  final categories = [
    {'key': 'kampung', 'label': 'Kampung Adat'},
    {'key': 'budaya', 'label': 'Budaya'},
    {'key': 'alam', 'label': 'Alam'},
    {'key': 'kuliner', 'label': 'Kuliner'},
    {'key': 'event', 'label': 'Event'},
    {'key': 'lainnya', 'label': 'Lainnya'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  // ── Fetch ──────────────────────────────────────────────
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/galleries');
      
      // Debug: Disabled to reduce log noise
      // debugPrint('═══════════════════════════════════════════');
      // debugPrint('[Gallery] Response keys: ${res.keys.toList()}');
      
      final raw = res['data'] ?? res['galleries'] ?? [];
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      
      // debugPrint('[Gallery] Total items: ${list.length}');
      
      // if (list.isNotEmpty) {
      //   final first = list.first;
      //   debugPrint('[Gallery] First item keys: ${first.keys.toList()}');
      //   debugPrint('[Gallery] id: ${first['id']}');
      //   debugPrint('[Gallery] title: ${first['title']}');
      //   debugPrint('[Gallery] image_path: ${first['image_path']}');
      //   debugPrint('[Gallery] full_url: ${first['full_url']}');
      //   debugPrint('[Gallery] image_url: ${first['image_url']}');
      //   debugPrint('[Gallery] url: ${first['url']}');
      //   debugPrint('[Gallery] path: ${first['path']}');
      //   debugPrint('[Gallery] Full first item: $first');
      // }
      // debugPrint('═══════════════════════════════════════════');
      
      galleries.value = list.map((e) => GalleryModel.fromJson(e)).toList();
      
      // Debug: Disabled to reduce log noise
      // if (galleries.isNotEmpty) {
      //   debugPrint('[Gallery] First gallery imageUrl: ${galleries.first.imageUrl}');
      // }
    } catch (e) {
      debugPrint('[Gallery] ❌ Error: $e');
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Pick multi image dari galeri ───────────────────────
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (files.isEmpty) return;
    // Tambahkan ke list yang sudah ada (tidak replace)
    selectedImages.addAll(files);
  }

  // ── Pick dari kamera (tambah ke list) ─────────────────
  Future<void> pickFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (file != null) selectedImages.add(file);
  }

  // ── Hapus satu foto dari preview ───────────────────────
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // ── Store batch ────────────────────────────────────────
  // Kirim satu per satu karena API hanya support single upload
  Future<void> store() async {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Judul harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    if (selectedImages.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih minimal satu foto.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    uploadProgress.value = 0;
    uploadTotal.value = selectedImages.length;

    int sukses = 0;
    int gagal = 0;
    final baseTitle = titleCtrl.text.trim();

    for (int i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];
      // Judul: "Nama" untuk 1 foto, "Nama (1)", "Nama (2)" untuk banyak
      final title = selectedImages.length == 1
          ? baseTitle
          : '$baseTitle (${i + 1})';
      try {
        final imageFile =
            await http.MultipartFile.fromPath('image', file.path);
        await _api.postMultipart(
          '/admin/galleries',
          fields: {
            'title': title,
            if (captionCtrl.text.trim().isNotEmpty)
              'caption': captionCtrl.text.trim(),
            'category': selectedCategory.value,
            'is_featured': (isFeatured.value && i == 0) ? '1' : '0',
          },
          files: [imageFile],
        );
        sukses++;
      } catch (_) {
        gagal++;
      }
      uploadProgress.value = i + 1;
    }

    isSubmitting.value = false;
    Get.back();
    await fetch();
    clearForm();

    if (sukses > 0) {
      Get.snackbar(
        'Berhasil',
        gagal == 0
            ? '$sukses foto berhasil diunggah.'
            : '$sukses berhasil, $gagal gagal.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('Gagal', 'Semua foto gagal diunggah.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  // ── Populate form untuk edit ───────────────────────────
  void populateForm(GalleryModel gallery) {
    isEditMode.value = true;
    editingGalleryId.value = gallery.id;
    titleCtrl.text = gallery.title;
    captionCtrl.text = gallery.caption ?? '';
    selectedCategory.value = gallery.category ?? 'kampung';
    isFeatured.value = gallery.isFeatured;
    selectedImages.clear(); // Edit tidak perlu ganti gambar (opsional)
  }

  // ── Update ─────────────────────────────────────────────
  Future<void> updateGallery() async {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Judul harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    final id = editingGalleryId.value;
    if (id == null) return;

    isSubmitting.value = true;
    try {
      // Jika ada gambar baru dipilih, gunakan multipart
      if (selectedImages.isNotEmpty) {
        final imageFile = await http.MultipartFile.fromPath(
            'image', selectedImages.first.path);
        await _api.postMultipart(
          '/admin/galleries/$id',
          fields: {
            '_method': 'PUT', // Laravel method spoofing
            'title': titleCtrl.text.trim(),
            if (captionCtrl.text.trim().isNotEmpty)
              'caption': captionCtrl.text.trim(),
            'category': selectedCategory.value,
            'is_featured': isFeatured.value ? '1' : '0',
          },
          files: [imageFile],
        );
      } else {
        // Jika tidak ada gambar baru, gunakan PUT biasa
        await _api.put('/admin/galleries/$id', {
          'title': titleCtrl.text.trim(),
          if (captionCtrl.text.trim().isNotEmpty)
            'caption': captionCtrl.text.trim(),
          'category': selectedCategory.value,
          'is_featured': isFeatured.value ? 1 : 0,
        });
      }

      Get.back();
      await fetch();
      clearForm();
      Get.snackbar('Berhasil', 'Foto berhasil diperbarui.',
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

  // ── Delete ─────────────────────────────────────────────
  Future<void> delete(int id) async {
    try {
      await _api.delete('/admin/galleries/$id');
      galleries.removeWhere((g) => g.id == id);
      Get.snackbar('Berhasil', 'Foto berhasil dihapus.',
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

  // ── Clear form ─────────────────────────────────────────
  void clearForm() {
    isEditMode.value = false;
    editingGalleryId.value = null;
    titleCtrl.clear();
    captionCtrl.clear();
    selectedCategory.value = 'kampung';
    isFeatured.value = false;
    selectedImages.clear();
    uploadProgress.value = 0;
    uploadTotal.value = 0;
  }

  @override
  void onClose() {
    // TextEditingControllers are NOT disposed here because this controller
    // uses fenix: true — GetX may recreate it, and disposing here causes
    // "used after being disposed" errors on re-entry.
    super.onClose();
  }
}
