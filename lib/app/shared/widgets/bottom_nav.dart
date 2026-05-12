import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../colors.dart';
import '../../routes/app_routes.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNav({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return;
    final routes = [
      AppRoutes.adminDashboard,
      AppRoutes.adminPackages,
      AppRoutes.adminEvents,
      AppRoutes.adminBookings,
      AppRoutes.adminGalleries,
    ];
    Get.offAllNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: const Border(top: BorderSide(color: Color(0xFFE8E2D0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.dashboard_outlined, 'Beranda', 0),
          _item(Icons.inventory_2_outlined, 'Paket', 1),
          _item(Icons.event_outlined, 'Event', 2),
          _item(Icons.receipt_long_outlined, 'Pemesanan', 3),
          _item(Icons.photo_library_outlined, 'Galeri', 4),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final active = currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 14 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? Colors.white : Colors.grey, size: 20),
            if (active) ...[
              const SizedBox(width: 5),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}
