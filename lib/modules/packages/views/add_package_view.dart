import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/shared/colors.dart';
import '../controllers/package_controller.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../app/shared/widgets/bottom_nav.dart';

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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3A30)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Package',
          style: TextStyle(
            color: Color(0xFF2D3A30),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Color(0xFF2D3A30)),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE PICKER
            Obx(() => GestureDetector(
              onTap: c.pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  image: c.selectedImage.value != null
                      ? DecorationImage(
                    image: FileImage(c.selectedImage.value!),
                    fit: BoxFit.cover,
                  )
                      : const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black26,
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: c.selectedImage.value == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF2D3A30),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Cover Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                    : null,
              ),
            )),

            const SizedBox(height: 24),

            // NAME
            _label('Package Name'),
            _field(c.nameCtrl, 'e.g. Traditional Weaving Workshop'),
            const SizedBox(height: 18),

            // PRICE & MIN PEOPLE
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Price (IDR)'),
                      _field(
                        c.priceCtrl,
                        '250.000',
                        prefix: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text('Rp'),
                        ),
                        type: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Min. People'),
                      _field(
                        c.minPeopleCtrl,
                        '2',
                        suffix: const Icon(Icons.group),
                        type: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // DESCRIPTION
            _label('Description'),
            _field(
              c.descCtrl,
              'description...',
              maxLines: 5,
            ),

            const SizedBox(height: 20),

            // OPTIONS
            Obx(() => _toggleCard(
              Icons.restaurant,
              'Includes Lunch',
              c.includeLunch.value,
                  (v) => c.includeLunch.value = v!,
              const Color(0xFFFDE68A),
              const Color(0xFFD97706),
            )),

            const SizedBox(height: 12),

            Obx(() => _toggleCard(
              Icons.map,
              'Local Guide',
              c.includeGuide.value,
                  (v) => c.includeGuide.value = v!,
              const Color(0xFFD1FAE5),
              const Color(0xFF059669),
            )),

            const SizedBox(height: 32),

            // BUTTON
            Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: c.isLoading.value ? null : c.save,
                child: Text(
                  c.isLoading.value ? 'Saving...' : 'Save Package',
                ),
              ),
            )),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Discard Changes'),
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
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3A30),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String hint, {
        TextInputType type = TextInputType.text,
        int maxLines = 1,
        Widget? prefix,
        Widget? suffix,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2D3A30)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: prefix != null ? Padding(padding: const EdgeInsets.only(left: 20), child: prefix) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 20), child: suffix) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _toggleCard(IconData icon, String title, bool value, Function(bool?) onChanged, Color iconBg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF2D3A30), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2D3A30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ],
      ),
    );
  }
}