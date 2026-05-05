import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../app/data/api_service.dart';
import '../../../app/data/models/event_model.dart';

class EventController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var events = <EventModel>[].obs;
  var error = ''.obs;
  var searchQuery = ''.obs;

  // Form fields untuk tambah/edit event
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  var selectedStatus = 'upcoming'.obs;
  var selectedDate = Rxn<DateTime>();
  var selectedImage = Rxn<XFile>(); // gambar yang dipilih

  List<EventModel> get filtered {
    if (searchQuery.value.isEmpty) return events;
    return events
        .where((e) =>
            e.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  int get activeCount =>
      events.where((e) => e.status == 'ongoing').length;
  int get upcomingCount =>
      events.where((e) => e.status == 'upcoming').length;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/events');
      final raw = res['data'] ?? [];
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      // DEBUG: print field gambar dari item pertama
      if (list.isNotEmpty) {
        final first = list.first;
        debugPrint('[EventController] Sample keys: ${first.keys.toList()}');
        debugPrint('[EventController] image_path: ${first['image_path']}');
        debugPrint('[EventController] full_url: ${first['full_url']}');
        debugPrint('[EventController] image_url: ${first['image_url']}');
        debugPrint('[EventController] image: ${first['image']}');
      }
      events.value = list.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (file != null) selectedImage.value = file;
  }

  Future<void> store() async {
    if (nameCtrl.text.trim().isEmpty || selectedDate.value == null) {
      Get.snackbar('Peringatan', 'Nama dan tanggal event harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final date = selectedDate.value!;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Pakai postMultipart karena backend support upload image
      final files = <http.MultipartFile>[];
      if (selectedImage.value != null) {
        files.add(await http.MultipartFile.fromPath(
          'image',
          selectedImage.value!.path,
        ));
      }

      await _api.postMultipart('/admin/events',
          fields: {
            'name': nameCtrl.text.trim(),
            'description': descCtrl.text.trim(),
            'event_date': dateStr,
            'location': locationCtrl.text.trim(),
            'status': selectedStatus.value,
          },
          files: files.isEmpty ? null : files);

      Get.back();
      fetch();
      Get.snackbar('Sukses', 'Event berhasil ditambahkan.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      clearForm();
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateEvent(int id) async {
    if (nameCtrl.text.trim().isEmpty || selectedDate.value == null) {
      Get.snackbar('Peringatan', 'Nama dan tanggal event harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final date = selectedDate.value!;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final files = <http.MultipartFile>[];
      if (selectedImage.value != null) {
        files.add(await http.MultipartFile.fromPath(
          'image',
          selectedImage.value!.path,
        ));
      }

      // Laravel pakai POST + _method=PUT untuk multipart
      await _api.postMultipart('/admin/events/$id',
          fields: {
            '_method': 'PUT',
            'name': nameCtrl.text.trim(),
            'description': descCtrl.text.trim(),
            'event_date': dateStr,
            'location': locationCtrl.text.trim(),
            'status': selectedStatus.value,
          },
          files: files.isEmpty ? null : files);

      Get.back();
      fetch();
      Get.snackbar('Sukses', 'Event berhasil diperbarui.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      clearForm();
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void fillFormForEdit(EventModel event) {
    nameCtrl.text = event.name;
    descCtrl.text = event.description;
    locationCtrl.text = event.location;
    selectedStatus.value = event.status;
    selectedImage.value = null;
    try {
      final date = DateTime.parse(event.eventDate);
      selectedDate.value = date;
      dateCtrl.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      selectedDate.value = null;
      dateCtrl.clear();
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete('/admin/events/$id');
      events.removeWhere((e) => e.id == id);
      Get.snackbar('Sukses', 'Event berhasil dihapus.',
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

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2D4236)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dateCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void clearForm() {
    nameCtrl.clear();
    descCtrl.clear();
    locationCtrl.clear();
    dateCtrl.clear();
    selectedDate.value = null;
    selectedStatus.value = 'upcoming';
    selectedImage.value = null;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }
}
