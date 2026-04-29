import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bajulan_mobile/app/shared/colors.dart';

class CustomBottomNav extends StatelessWidget {
  // Kita gunakan RxInt supaya posisi menu yang aktif bisa dipantau GetX
  final RxInt currentIndex = 0.obs;

  CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7).withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: const Border(top: BorderSide(color: Color(0xFFE8E2D0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Home', 0),
          _buildNavItem(Icons.inventory_2_outlined, 'Packages', 1),
          _buildNavItem(Icons.event_outlined, 'Events', 2),
          _buildNavItem(Icons.receipt_long_outlined, 'Bookings', 3),
        ],
      )),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = currentIndex.value == index;

    return GestureDetector(
        onTap: () {
      currentIndex.value = index;
      if (index == 0) Get.toNamed('/dashboard');
      if (index == 2) Get.toNamed('/events'); // Navigasi ke halaman Event
      // Tambahkan rute lainnya sesuai index
    },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}