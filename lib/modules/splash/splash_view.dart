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
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnim = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();

    // Navigate setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    final auth = Get.find<AuthService>();
    final route = auth.isLoggedIn.value
        ? AppRoutes.adminDashboard
        : AppRoutes.home;
    Get.offNamed(route);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Ornamen sudut kiri atas ────────────────────
          Positioned(
            top: -40,
            left: -40,
            child: _OrnamentCircle(size: 200, opacity: 0.06),
          ),
          // ── Ornamen sudut kanan bawah ──────────────────
          Positioned(
            bottom: -60,
            right: -60,
            child: _OrnamentCircle(size: 280, opacity: 0.05),
          ),
          // ── Ornamen kecil kanan atas ───────────────────
          Positioned(
            top: 80,
            right: 30,
            child: _OrnamentCircle(size: 80, opacity: 0.08),
          ),
          // ── Ornamen kecil kiri bawah ───────────────────
          Positioned(
            bottom: 120,
            left: 20,
            child: _OrnamentCircle(size: 60, opacity: 0.07),
          ),

          // ── Konten utama ───────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Icon/Logo ──────────────────────
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.temple_hindu_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Nama app ───────────────────────
                        const Text(
                          'Kampung Adat',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bajulan',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Divider ornamen ────────────────
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 1,
                              color: AppColors.muted,
                            ),
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
                              width: 32,
                              height: 1,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Tagline ────────────────────────
                        const Text(
                          'Nganjuk, Jawa Timur',
                          style: TextStyle(
                            color: AppColors.outline,
                            fontSize: 13,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Loading indicator bawah ────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: const Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Memuat...',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        letterSpacing: 1,
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

// ── Ornament circle ────────────────────────────────────────
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
          color: AppColors.primary.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
