import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bajulan_mobile/app/shared/colors.dart';
import 'package:bajulan_mobile/modules/login/controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1596401057633-531035736461?q=80&w=1000',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurCircle(AppColors.secondary.withOpacity(0.1), 300),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildLoginCard(controller),
                  const SizedBox(height: 40),
                  Text(
                    'Versi 2.4.0 • Bajulan Digital Ecosystem',
                    style: TextStyle(
                      color: AppColors.outline,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Transform.rotate(
          angle: 0.08,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: const Icon(Icons.temple_hindu, color: Colors.white, size: 48),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kampung Adat Bajulan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'Sistem Administrasi Pariwisata',
          style: TextStyle(color: AppColors.outline, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLoginCard(LoginController controller) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masuk Akun',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const Text(
            'Kelola operasional desa dengan bijak.',
            style: TextStyle(color: AppColors.outline, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildFieldLabel('Username'),
          _buildTextField(hint: 'admin_bajulan', icon: Icons.person_2_outlined),
          const SizedBox(height: 20),
          _buildFieldLabel('Kata Sandi'),
          Obx(() => _buildTextField(
            hint: '••••••••',
            icon: Icons.lock_person_outlined,
            isPassword: true,
            obscureText: controller.isObscured.value,
            onToggle: () => controller.toggleObscure(),
          )),
          const SizedBox(height: 12),

          // Row untuk Ingat Saya & Lupa Sandi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Obx(() => Checkbox(
                      value: controller.rememberMe.value,
                      activeColor: AppColors.primary,
                      onChanged: (val) => controller.toggleRemember(val),
                    )),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ingat saya', style: TextStyle(fontSize: 13)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lupa sandi?',
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tombol Login (Satu saja, lebar penuh)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () => controller.login(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Masuk ke Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0EDE9), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.outline),
          prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.5)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: AppColors.outline),
            onPressed: onToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}