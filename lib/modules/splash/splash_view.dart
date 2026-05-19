import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/auth_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/shared/colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    final auth = Get.find<AuthService>();
    final route = auth.isLoggedIn.value
        ? AppRoutes.adminDashboard
        : AppRoutes.login;
    Get.offNamed(route);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Ornamen lingkaran sudut ────────────────────
          Positioned(
            top: -size.width * 0.25,
            left: -size.width * 0.25,
            child: _OrnamentCircle(
                size: size.width * 0.7, opacity: 0.06),
          ),
          Positioned(
            bottom: -size.width * 0.3,
            right: -size.width * 0.3,
            child: _OrnamentCircle(
                size: size.width * 0.8, opacity: 0.05),
          ),
          Positioned(
            top: size.height * 0.12,
            right: size.width * 0.06,
            child: _OrnamentCircle(size: 70, opacity: 0.07),
          ),
          Positioned(
            bottom: size.height * 0.15,
            left: size.width * 0.04,
            child: _OrnamentCircle(size: 50, opacity: 0.07),
          ),

          // ── Konten utama ───────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo ──────────────────────────
                      SizedBox(
                        width: size.width * 0.68,
                        height: size.width * 0.68,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.temple_hindu_rounded,
                            color: AppColors.tertiary,
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Nama ──────────────────────────
                      const Text(
                        'KAMPUNG ADAT',
                        style: TextStyle(
                          color: AppColors.outline,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Bajulan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Divider ornamen ───────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 36, height: 1, color: AppColors.muted),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                              width: 36, height: 1, color: AppColors.muted),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Tagline ───────────────────────
                      const Text(
                        'Nganjuk, Jawa Timur',
                        style: TextStyle(
                          color: AppColors.outline,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Loading indicator ──────────────────────────
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: const Column(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Memuat...',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _OrnamentCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
