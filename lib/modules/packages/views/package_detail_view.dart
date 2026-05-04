import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/network_image_widget.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../controllers/package_detail_controller.dart';

class PackageDetailView extends StatelessWidget {
  const PackageDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PackageDetailController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (c.error.isNotEmpty) {
          return ErrorState(
              message: c.error.value,
              onRetry: () => c.fetchDetail(int.parse(Get.parameters['id']!)));
        }
        final pkg = c.package.value!;
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: AppNetworkImage(
                  url: pkg.coverImage,
                  width: double.infinity,
                  height: 260,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(pkg.categoryLabel,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text(pkg.name,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Price & min person
                    Row(
                      children: [
                        _infoChip(Icons.payments_outlined,
                            '${fmt.format(pkg.pricePerPerson)} / orang', AppColors.secondary),
                        const SizedBox(width: 12),
                        _infoChip(Icons.group_outlined,
                            'Min. ${pkg.minPerson} orang', AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _sectionTitle('Deskripsi'),
                    const SizedBox(height: 8),
                    Text(pkg.description,
                        style: const TextStyle(
                            color: AppColors.onSurface, fontSize: 14, height: 1.6)),

                    if (pkg.terms.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionTitle('Syarat & Ketentuan'),
                      const SizedBox(height: 8),
                      Text(pkg.terms,
                          style: const TextStyle(
                              color: AppColors.outline, fontSize: 13, height: 1.6)),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (c.isLoading.value || c.package.value == null) return const SizedBox.shrink();
        final pkg = c.package.value!;
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE8E2D0))),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mulai dari',
                      style: TextStyle(color: AppColors.outline, fontSize: 11)),
                  Text(fmt.format(pkg.pricePerPerson),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/booking/${pkg.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Pesan Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold));
  }
}
