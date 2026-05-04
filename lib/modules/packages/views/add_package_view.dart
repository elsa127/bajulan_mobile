import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/shared/colors.dart';
import '../controllers/package_controller.dart';

class AddPackageView extends StatelessWidget {
  const AddPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PackageController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Tambah Paket',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
        shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Nama Paket *'),
            _field(c.nameCtrl, 'Contoh: Paket Soan'),
            const SizedBox(height: 16),

            _label('Kategori'),
            Obx(() => DropdownButtonFormField<String>(
                  initialValue: c.selectedCategory.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF0EDE9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: c.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat['key'],
                            child: Text(cat['label']!),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedCategory.value = v!,
                )),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Harga / Orang (Rp) *'),
                      _field(c.priceCtrl, '75000',
                          type: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Min. Orang *'),
                      _field(c.minPeopleCtrl, '5',
                          type: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Deskripsi'),
            _field(c.descCtrl, 'Ceritakan pengalaman yang ditawarkan...',
                maxLines: 4),
            const SizedBox(height: 16),

            _label('Syarat & Ketentuan'),
            _field(c.termsCtrl, 'Syarat dan ketentuan paket...', maxLines: 3),
            const SizedBox(height: 32),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: c.isLoading.value ? null : c.save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Paket',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal',
                    style: TextStyle(color: AppColors.outline, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF0EDE9), borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
