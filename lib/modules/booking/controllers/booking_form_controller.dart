import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/package_model.dart';
import '../../../app/routes/app_routes.dart';

class BookingFormController extends GetxController {
  final _api = Get.find<ApiService>();

  // Package yang dipilih
  var package = Rxn<PackageModel>();
  var isLoadingPackage = true.obs;

  // Form controllers
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final personCtrl = TextEditingController(text: '1');

  var visitDate = Rxn<DateTime>();
  var isSubmitting = false.obs;
  var personCount = 1.obs; // reactive untuk estimasi total

  @override
  void onInit() {
    super.onInit();
    personCtrl.addListener(() {
      personCount.value = int.tryParse(personCtrl.text) ?? 0;
    });
    final id = Get.parameters['id'];
    if (id != null) _fetchPackage(int.parse(id));
  }

  Future<void> _fetchPackage(int id) async {
    isLoadingPackage.value = true;
    try {
      final res = await _api.get('/packages/$id');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      package.value = PackageModel.fromJson(data);
      // set default min person
      personCtrl.text = package.value!.minPerson.toString();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoadingPackage.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2D4236)),
        ),
        child: child!,
      ),
    );
    if (picked != null) visitDate.value = picked;
  }

  Future<void> submit() async {
    if (nameCtrl.text.trim().isEmpty) {
      _snack('Nama tamu harus diisi.');
      return;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      _snack('Nomor HP harus diisi.');
      return;
    }
    if (visitDate.value == null) {
      _snack('Tanggal kunjungan harus dipilih.');
      return;
    }
    final persons = int.tryParse(personCtrl.text) ?? 0;
    if (persons < (package.value?.minPerson ?? 1)) {
      _snack('Minimal ${package.value?.minPerson ?? 1} orang.');
      return;
    }

    isSubmitting.value = true;
    try {
      final res = await _api.post('/bookings', {
        'package_id': package.value!.id,
        'guest_name': nameCtrl.text.trim(),
        'guest_phone': phoneCtrl.text.trim(),
        if (emailCtrl.text.trim().isNotEmpty) 'guest_email': emailCtrl.text.trim(),
        'visit_date':
            '${visitDate.value!.year}-${visitDate.value!.month.toString().padLeft(2, '0')}-${visitDate.value!.day.toString().padLeft(2, '0')}',
        'total_person': persons,
        if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
      });

      final data = res['data'] as Map<String, dynamic>? ?? res;
      final bookingCode = data['booking_code'] as String? ?? '';
      final snapToken = data['snap_token'] as String? ?? '';

      Get.offNamed(AppRoutes.payment, arguments: {
        'booking_code': bookingCode,
        'snap_token': snapToken,
      });
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _snack(String msg) {
    Get.snackbar('Peringatan', msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    notesCtrl.dispose();
    personCtrl.dispose();
    super.onClose();
  }
}
