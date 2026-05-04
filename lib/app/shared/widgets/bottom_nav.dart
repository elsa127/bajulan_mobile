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
          _item(Icons.dashboard_outlined, 'Home', 0),
          _item(Icons.inventory_2_outlined, 'Packages', 1),
          _item(Icons.event_outlined, 'Events', 2),
          _item(Icons.receipt_long_outlined, 'Bookings', 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : Colors.grey, size: 22),
            if (active) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}
