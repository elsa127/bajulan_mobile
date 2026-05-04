import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/data/auth_service.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final auth = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: _buildAppBar(auth),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (c.error.isNotEmpty) {
          return ErrorState(message: c.error.value, onRetry: c.fetch);
        }
        final d = c.dashboard.value;
        return RefreshIndicator(
          onRefresh: c.fetch,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──────────────────────────────
                _buildGreeting(auth),
                const SizedBox(height: 20),

                if (d != null) ...[
                  // ── Total Booking Hari Ini ─────────────
                  _buildMainStatCard(d),
                  const SizedBox(height: 12),

                  // ── Pendapatan + Paket Aktif ───────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallCard(
                          icon: Icons.payments_outlined,
                          iconColor: AppColors.secondary,
                          label: 'Pendapatan bulan ini',
                          value: _formatRevenue(d.totalPendapatanBulanIni),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallCard(
                          icon: Icons.inventory_2_outlined,
                          iconColor: AppColors.tertiary,
                          label: 'Paket aktif',
                          value: d.jumlahPaketAktif.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Ongoing Events ─────────────────────
                _buildSectionHeader('Ongoing Events', onTap: () => Get.toNamed(AppRoutes.adminEvents)),
                const SizedBox(height: 12),
                Obx(() => _buildEventsSection(c)),
                const SizedBox(height: 24),

                // ── Recent Bookings ────────────────────
                if (d != null && d.bookingTerbaru.isNotEmpty) ...[
                  _buildSectionHeader('Recent Bookings'),
                  const SizedBox(height: 12),
                  ...d.bookingTerbaru.map((b) => _buildBookingItem(b)),
                ],
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.adminAddPackage),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(AuthService auth) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F0E8),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Bajulan Admin',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.primary, size: 24),
        ),
        IconButton(
          onPressed: () => _confirmLogout(auth),
          icon: const Icon(Icons.logout_rounded,
              color: AppColors.primary, size: 20),
        ),
      ],
    );
  }

  // ── Greeting ───────────────────────────────────────────
  Widget _buildGreeting(AuthService auth) {
    final today = DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Obx(() => Text(
              'Sugeng Rawuh, ${auth.userName}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )),
      ],
    );
  }

  // ── Main Stat Card (Total Booking Hari Ini) ──────────
  Widget _buildMainStatCard(d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total booking hari ini',
                style: TextStyle(color: AppColors.outline, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                d.totalBookingHariIni.toString(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    '+12% dari kemarin',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppColors.primary, size: 26),
          ),
        ],
      ),
    );
  }

  // ── Small Stat Card ────────────────────────────────────
  Widget _buildSmallCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(color: AppColors.outline, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'View all',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ── Events Section ─────────────────────────────────────
  Widget _buildEventsSection(DashboardController c) {
    final d = c.dashboard.value;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D5A47), Color(0xFF1A2E22)],
              ),
            ),
          ),
          // Decorative circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIVE NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bersih Desa Festival',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${d?.jumlahPaketAktif ?? 0} Paket Aktif • Punden Bajulan',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Booking Item ───────────────────────────────────────
  Widget _buildBookingItem(Map<String, dynamic> b) {
    final status = b['status'] as String? ?? 'pending';
    final packageName = (b['package'] as Map<String, dynamic>?)?['name']
            as String? ??
        '-';
    final guestName = b['guest_name'] as String? ?? '-';
    final visitDate = b['visit_date'] as String? ?? '';

    final isConfirmed = status == 'confirmed' || status == 'paid';
    final statusColor = isConfirmed
        ? Colors.green
        : status == 'pending'
            ? Colors.orange
            : Colors.red;
    final statusBg = isConfirmed
        ? Colors.green.withValues(alpha: 0.1)
        : status == 'pending'
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.temple_hindu,
                color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  visitDate.isNotEmpty ? '$guestName • $visitDate' : guestName,
                  style: const TextStyle(
                      color: AppColors.outline, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────
  String _formatRevenue(int revenue) {
    if (revenue >= 1000000) {
      final m = revenue / 1000000;
      return 'Rp ${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return 'Rp ${(revenue / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp $revenue';
  }

  void _confirmLogout(AuthService auth) {
    Get.dialog(AlertDialog(
      title: const Text('Logout?'),
      content: const Text('Anda akan keluar dari panel admin.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child:
                const Text('Batal', style: TextStyle(color: AppColors.outline))),
        TextButton(
            onPressed: () {
              Get.back();
              auth.logout();
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}
