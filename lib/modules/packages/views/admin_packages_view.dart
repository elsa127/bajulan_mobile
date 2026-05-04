import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/network_image_widget.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/admin_packages_controller.dart';

class AdminPackagesView extends StatelessWidget {
  const AdminPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminPackagesController>();
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        title: const Text('Paket Wisata',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
        shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0))),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.adminAddPackage),
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (c.error.isNotEmpty) {
          return ErrorState(message: c.error.value, onRetry: c.fetch);
        }
        if (c.packages.isEmpty) {
          return const Center(
              child: Text('Belum ada paket.', style: TextStyle(color: AppColors.outline)));
        }
        return RefreshIndicator(
          onRefresh: c.fetch,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: c.packages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final pkg = c.packages[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    AppNetworkImage(
                      url: pkg.coverImage,
                      width: 90,
                      height: 90,
                      borderRadius:
                          const BorderRadius.horizontal(left: Radius.circular(18)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.name,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(pkg.categoryLabel,
                                style: const TextStyle(
                                    color: AppColors.outline, fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(fmt.format(pkg.pricePerPerson),
                                style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.primary, size: 20),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(c, pkg.id, pkg.name),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.adminAddPackage),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  void _confirmDelete(AdminPackagesController c, int id, String name) {
    Get.dialog(AlertDialog(
      title: const Text('Hapus Paket?'),
      content: Text('Paket "$name" akan dihapus permanen.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: AppColors.outline))),
        TextButton(
            onPressed: () {
              Get.back();
              c.delete(id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}
