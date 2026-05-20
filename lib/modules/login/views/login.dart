import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/shared/colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildCard(),
                const SizedBox(height: 24),
                _buildFooter(),
                const SizedBox(height: 16),
                const Text(
                  'Versi 1.0 • Bajulan Digital Ecosystem',
                  style: TextStyle(color: AppColors.outline, fontSize: 11),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.temple_hindu, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 14),
        const Text(
          'Kampung Adat Bajulan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sistem Administrasi Pariwisata',
          style: TextStyle(color: AppColors.outline, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masuk Akun',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola operasional desa dengan bijak.',
            style: TextStyle(color: AppColors.outline, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Username
          _label('Username'),
          Obx(() => _inputField(
            controller: controller.usernameCtrl,
            hint: 'admin_bajulan',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            hasError: controller.usernameError.value,
          )),
          const SizedBox(height: 16),

          // Password
          _label('Kata Sandi'),
          Obx(() => _passwordField()),
          const SizedBox(height: 12),

          // Remember me + Lupa sandi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: (_) => controller.toggleRemember(),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ingat saya',
                        style: TextStyle(
                            color: AppColors.onSurface, fontSize: 13),
                      ),
                    ],
                  )),
              TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Lupa Sandi',
                    'Hubungi admin IT untuk reset kata sandi.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lupa sandi?',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Login button
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Masuk ke Dashboard',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Butuh bantuan akses?',
          style: TextStyle(color: AppColors.outline, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink(
              icon: Icons.support_agent_outlined,
              label: 'Bantuan IT',
              onTap: () => _launchUrl('https://wa.me/6281234567890'),
            ),
            const SizedBox(width: 20),
            _footerLink(
              icon: Icons.language_outlined,
              label: 'Situs Desa',
              onTap: () => _launchUrl('https://kampungadatbajulan.pbltifnganjuk.com'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.error.withValues(alpha: 0.06)
            : const Color(0xFFF5F2ED),
        borderRadius: BorderRadius.circular(12),
        border: hasError
            ? Border.all(color: AppColors.error, width: 1.5)
            : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.muted, fontSize: 14),
          prefixIcon: Icon(
            icon,
            color: hasError ? AppColors.error : AppColors.muted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _passwordField() {
    final hasError = controller.passwordError.value;
    return Container(
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.error.withValues(alpha: 0.06)
            : const Color(0xFFF5F2ED),
        borderRadius: BorderRadius.circular(12),
        border: hasError
            ? Border.all(color: AppColors.error, width: 1.5)
            : null,
      ),
      child: TextField(
        controller: controller.passwordCtrl,
        obscureText: controller.isObscured.value,
        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(color: AppColors.muted),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: hasError ? AppColors.error : AppColors.muted,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isObscured.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.muted,
              size: 20,
            ),
            onPressed: controller.toggleObscure,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
