import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/shared/colors.dart';
import '../controllers/package_controller.dart';

class AddPackageView extends StatelessWidget {
  const AddPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(PackageController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildImageUpload(),
            const SizedBox(height: 24),
            _buildFormSection(controller),
            const SizedBox(height: 32),
            _buildActionButtons(controller),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFDFBF7),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Add Package',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
        ),
      ],
      shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0))),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Upload Cover Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('PNG, JPG up to 10MB', style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFormSection(PackageController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Package Name'),
        _buildInsetField(hint: 'e.g. Traditional Weaving Workshop', controller: controller.nameController),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Price (IDR)'),
                  _buildInsetField(hint: '250.000', prefix: 'Rp', isNumber: true, controller: controller.priceController),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Min. People'),
                  _buildInsetField(hint: '2', suffix: Icons.group, isNumber: true, controller: controller.minPeopleController),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLabel('Description'),
        _buildInsetField(hint: 'Tell visitors about the experience...', isTextArea: true, controller: controller.descController),
        const SizedBox(height: 24),

        // Bento Style Toggle
        _buildToggleCard(
            icon: Icons.restaurant,
            label: 'Includes Lunch',
            value: controller.includeLunch,
            color: AppColors.secondary.withOpacity(0.1)
        ),
        const SizedBox(height: 12),
        _buildToggleCard(
            icon: Icons.map,
            label: 'Local Guide',
            value: controller.includeGuide,
            color: AppColors.tertiary.withOpacity(0.1)
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildInsetField({
    required String hint,
    required TextEditingController controller,
    String? prefix,
    IconData? suffix,
    bool isNumber = false,
    bool isTextArea = false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-2, -2), blurRadius: 4),
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(2, 2), blurRadius: 4),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: isTextArea ? 4 : 1,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          prefixIcon: prefix != null ? Container(width: 40, alignment: Alignment.center, child: Text(prefix)) : null,
          suffixIcon: suffix != null ? Icon(suffix, color: Colors.grey, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildToggleCard({required IconData icon, required String label, required RxBool value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Obx(() => Checkbox(
            value: value.value,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (v) => value.value = v!,
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PackageController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: () => controller.savePackage(),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Package', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Discard Changes', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}