import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/event_model.dart';
import '../../../app/data/models/package_model.dart';

class EventController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var events = <EventModel>[].obs;
  var error = ''.obs;
  var searchQuery = ''.obs;

  // Daftar paket untuk dropdown
  var packages = <PackageModel>[].obs;
  var isLoadingPackages = false.obs;

  // Form fields
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final startTimeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();
  var selectedStatus = 'upcoming'.obs;
  var selectedDate = Rxn<DateTime>();
  var selectedStartTime = Rxn<TimeOfDay>();
  var selectedEndTime = Rxn<TimeOfDay>();
  var selectedPackageId = Rxn<int>();

  List<EventModel> get filtered {
    if (searchQuery.value.isEmpty) return events;
    return events
        .where((e) =>
            e.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  int get activeCount => events.where((e) => e.status == 'ongoing').length;
  int get upcomingCount => events.where((e) => e.status == 'upcoming').length;

  @override
  void onInit() {
    super.onInit();
    fetch();
    fetchPackages();
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
      events.value = list.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPackages() async {
    isLoadingPackages.value = true;
    try {
      final res = await _api.get('/admin/packages');
      final raw = res['data'] ?? [];
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      packages.value = list.map((e) => PackageModel.fromJson(e)).toList();
    } catch (_) {
      // Gagal fetch paket tidak perlu tampilkan error
    } finally {
      isLoadingPackages.value = false;
    }
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
      final dateStr = _formatDate(selectedDate.value!);
      final body = <String, dynamic>{
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'event_date': dateStr,
        'location': locationCtrl.text.trim(),
        'status': selectedStatus.value,
        if (selectedStartTime.value != null)
          'start_time': _formatTime(selectedStartTime.value!),
        if (selectedEndTime.value != null)
          'end_time': _formatTime(selectedEndTime.value!),
      };
      if (selectedPackageId.value != null) {
        body['package_id'] = selectedPackageId.value;
      }

      await _api.post('/admin/events', body);

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
      final dateStr = _formatDate(selectedDate.value!);
      final body = <String, dynamic>{
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'event_date': dateStr,
        'location': locationCtrl.text.trim(),
        'status': selectedStatus.value,
        'package_id': selectedPackageId.value,
        'start_time': selectedStartTime.value != null
            ? _formatTime(selectedStartTime.value!)
            : null,
        'end_time': selectedEndTime.value != null
            ? _formatTime(selectedEndTime.value!)
            : null,
      };

      await _api.put('/admin/events/$id', body);

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
    selectedPackageId.value = event.packageId;
    // Parse start/end time
    if (event.startTime != null && event.startTime!.isNotEmpty) {
      final parts = event.startTime!.split(':');
      if (parts.length >= 2) {
        selectedStartTime.value = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0);
        startTimeCtrl.text = event.startTime!.substring(0, 5);
      }
    } else {
      selectedStartTime.value = null;
      startTimeCtrl.clear();
    }
    if (event.endTime != null && event.endTime!.isNotEmpty) {
      final parts = event.endTime!.split(':');
      if (parts.length >= 2) {
        selectedEndTime.value = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0);
        endTimeCtrl.text = event.endTime!.substring(0, 5);
      }
    } else {
      selectedEndTime.value = null;
      endTimeCtrl.clear();
    }
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
          colorScheme:
              const ColorScheme.light(primary: Color(0xFF2D4236)),
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
    startTimeCtrl.clear();
    endTimeCtrl.clear();
    selectedDate.value = null;
    selectedStartTime.value = null;
    selectedEndTime.value = null;
    selectedStatus.value = 'upcoming';
    selectedPackageId.value = null;
  }

  Future<void> pickTime(BuildContext context, {required bool isStart}) async {
    final initial = isStart
        ? (selectedStartTime.value ?? const TimeOfDay(hour: 8, minute: 0))
        : (selectedEndTime.value ?? const TimeOfDay(hour: 17, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2D4236)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        selectedStartTime.value = picked;
        startTimeCtrl.text = formatted;
      } else {
        selectedEndTime.value = picked;
        endTimeCtrl.text = formatted;
      }
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    dateCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    super.onClose();
  }
}
