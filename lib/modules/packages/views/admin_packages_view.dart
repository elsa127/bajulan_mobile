import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/admin_packages_controller.dart';
import '../../../app/shared/widgets/package_card.dart';

class AdminPackagesView extends StatelessWidget {
  const AdminPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminPackagesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manage Packages',
                    style: TextStyle(
                      color: Color(0xFF2D3A30),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF2D3A30)),
                    ),
                  ),
                ],
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDE8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (value) => c.searchQuery.value = value,
                  decoration: const InputDecoration(
                    hintText: 'Search packages...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    icon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- FILTER CHIPS ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() => Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: c.selectedFilter.value == 'all',
                    onSelected: (_) => c.selectedFilter.value = 'all',
                  ),
                  const SizedBox(width: 10),

                  ChoiceChip(
                    label: const Text('Cultural'),
                    selected: c.selectedFilter.value == 'cultural',
                    onSelected: (_) => c.selectedFilter.value = 'cultural',
                  ),
                  const SizedBox(width: 10),

                  ChoiceChip(
                    label: const Text('Nature'),
                    selected: c.selectedFilter.value == 'nature',
                    onSelected: (_) => c.selectedFilter.value = 'nature',
                  ),
                  const SizedBox(width: 10),

                  ChoiceChip(
                    label: const Text('Adventure'),
                    selected: c.selectedFilter.value == 'adventure',
                    onSelected: (_) => c.selectedFilter.value = 'adventure',
                  ),
                ],
              )),
            ),
            const SizedBox(height: 20),

            // --- PACKAGE LIST ---
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (c.error.isNotEmpty) {
                  return ErrorState(message: c.error.value, onRetry: c.fetch);
                }

                if (c.filteredPackages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada paket.',
                      style: TextStyle(color: AppColors.outline),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: c.fetch,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: c.filteredPackages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final pkg = c.filteredPackages[index];
                      return PackageCard(
                        package: pkg,
                        // Navigasi ke halaman edit dengan ID paket
                        onEdit: () => Get.toNamed('/admin/packages/edit/${pkg.id}'),
                        onDelete: () => _confirmDelete(c, pkg.id, pkg.name),
                        onPublish: () {
                          // Logic publish jika diperlukan
                          Get.snackbar('Sukses', 'Paket "${pkg.name}" telah dipublish.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.adminAddPackage), // Navigasi ke tambah paket
        backgroundColor: const Color(0xFF2D3A30),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2D3A30) : const Color(0xFFEEEAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _confirmDelete(AdminPackagesController c, int id, String name) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hapus Paket?'),
      content: Text('Paket "$name" akan dihapus secara permanen dari sistem.'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal', style: TextStyle(color: AppColors.outline)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            c.delete(id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Hapus'),
        ),
      ],
    ));
  }
}