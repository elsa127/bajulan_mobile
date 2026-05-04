import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/shared/colors.dart';
import '../../../../app/shared/widgets/network_image_widget.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/data/models/package_model.dart';
import '../../../../app/data/models/event_model.dart';
import '../controllers/home_controller.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: c.fetchAll,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(c),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildCategories(c)),
            SliverToBoxAdapter(child: _buildPackagesSection(c)),
            SliverToBoxAdapter(child: _buildEventsSection(c)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.bookingStatus),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text('Cek Booking', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAppBar(HomeController c) {
    return SliverAppBar(
      backgroundColor: AppColors.primary,
      expandedHeight: 0,
      floating: true,
      snap: true,
      title: Row(
        children: [
          const Icon(Icons.temple_hindu, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          const Text('Kampung Adat Bajulan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.login),
          child: const Text('Admin', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: 'https://images.unsplash.com/photo-1596401057633-531035736461?q=80&w=1200',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.primary.withValues(alpha: 0.85)],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat Datang di',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('Kampung Adat Bajulan',
                    style: TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Nganjuk, Jawa Timur',
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(HomeController c) {
    final cats = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'kampung_adat', 'label': 'Kampung Adat'},
      {'key': 'budaya_seni', 'label': 'Budaya & Seni'},
      {'key': 'edukasi_durian', 'label': 'Edukasi Durian'},
      {'key': 'pendakian', 'label': 'Pendakian'},
      {'key': 'trabas', 'label': 'Trabas'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Obx(() {
            final active = c.selectedCategory.value == cats[i]['key'];
            return GestureDetector(
              onTap: () => c.selectedCategory.value = cats[i]['key']!,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? AppColors.primary : AppColors.muted),
                ),
                child: Text(
                  cats[i]['label']!,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPackagesSection(HomeController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paket Wisata',
              style: TextStyle(
                  color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Pilih pengalaman terbaik untuk kunjungan Anda',
              style: TextStyle(color: AppColors.outline, fontSize: 12)),
          const SizedBox(height: 16),
          Obx(() {
            if (c.isLoadingPackages.value) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ));
            }
            if (c.errorPackages.isNotEmpty) {
              return Center(
                child: Column(
                  children: [
                    Text(c.errorPackages.value,
                        style: const TextStyle(color: AppColors.outline)),
                    TextButton(
                        onPressed: c.fetchPackages,
                        child: const Text('Coba Lagi',
                            style: TextStyle(color: AppColors.primary))),
                  ],
                ),
              );
            }
            final list = c.filteredPackages;
            if (list.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Tidak ada paket tersedia.',
                    style: TextStyle(color: AppColors.outline)),
              ));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _PackageCard(package: list[i]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventsSection(HomeController c) {
    return Obx(() {
      if (c.isLoadingEvents.value || c.events.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Mendatang',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: c.events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _EventChip(event: c.events[i]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Package Card ────────────────────────────────────────
class _PackageCard extends StatelessWidget {
  final PackageModel package;
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return GestureDetector(
      onTap: () => Get.toNamed('/package/${package.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            AppNetworkImage(
              url: package.coverImage,
              width: 110,
              height: 110,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(package.categoryLabel,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text(package.name,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(package.description,
                        style: const TextStyle(color: AppColors.outline, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(fmt.format(package.pricePerPerson),
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Text('min. ${package.minPerson} org',
                            style: const TextStyle(
                                color: AppColors.outline, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event Chip ──────────────────────────────────────────
class _EventChip extends StatelessWidget {
  final EventModel event;
  const _EventChip({required this.event});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              url: event.imageUrl,
              width: 200,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(event.eventDate,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
