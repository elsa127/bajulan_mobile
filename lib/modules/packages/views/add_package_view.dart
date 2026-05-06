import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/xfile_image_widget.dart';
import '../controllers/package_controller.dart';

class AddPackageView extends StatelessWidget {
  const AddPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PackageController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE PICKER
            _label('Foto Cover'),
            Obx(() => GestureDetector(
                  onTap: c.pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: c.coverImageFile.value != null
                        ? XFileImage(
                            xfile: c.coverImageFile.value!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_outlined,
                                    color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(height: 12),
                              const Text('Upload Cover Image',
                                  style: TextStyle(
                                      color: AppColors.outline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                  ),
                )),
            const SizedBox(height: 24),

            // NAME
            _label('Nama Paket *'),
            _field(c.nameCtrl, 'Contoh: Paket Soan'),
            const SizedBox(height: 18),

            // CATEGORY
            _label('Kategori'),
            Obx(() => DropdownButtonFormField<String>(
                  value: c.selectedCategory.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1EDE8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  items: c.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat['key'],
                            child: Text(cat['label']!),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedCategory.value = v!,
                )),
            const SizedBox(height: 18),

            // PRICE & MIN PEOPLE
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
                const SizedBox(width: 16),
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
            const SizedBox(height: 18),

            // DESCRIPTION
            _label('Deskripsi'),
            _field(c.descCtrl, 'Ceritakan pengalaman yang ditawarkan...', maxLines: 4),
            const SizedBox(height: 18),

            // TERMS
            _label('Syarat & Ketentuan'),
            _field(c.termsCtrl, 'Syarat dan ketentuan paket...', maxLines: 3),
            const SizedBox(height: 32),

            // SAVE BUTTON
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: c.isLoading.value ? null : c.save,
                    icon: c.isLoading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: Text(
                        c.isLoading.value ? 'Menyimpan...' : 'Simpan Paket',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal',
                    style: TextStyle(
                        color: AppColors.outline, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF1EDE8), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
