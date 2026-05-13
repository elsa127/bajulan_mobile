import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/network_image_widget.dart';
import '../../../app/shared/widgets/xfile_image_widget.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/admin_packages_controller.dart';
import '../../../app/data/models/package_model.dart';

class AdminPackagesView extends StatelessWidget {
  const AdminPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminPackagesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ── Header ──────────────────────────────────
            Container(
              color: AppColors.background,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paket Wisata',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kelola paket wisata Kampung Adat Bajulan',
                          style: TextStyle(
                              color: AppColors.outline, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.adminAddPackage),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah\nPaket',
                        style: TextStyle(fontSize: 11, height: 1.2)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppColors.spaceXl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppColors.spaceL),
                decoration: AppColors.inputDecoration,
                child: TextField(
                  onChanged: (v) => c.searchQuery.value = v,
                  decoration: const InputDecoration(
                    hintText: 'Cari paket...',
                    hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                    icon: Icon(Icons.search, color: AppColors.muted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppColors.spaceL),

            // ── Filter chips ─────────────────────────────
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _chip(c, 'all', 'Semua Paket'),
                      const SizedBox(width: 10),
                      _chip(c, 'kampung_adat', 'Budaya'),
                      const SizedBox(width: 10),
                      _chip(c, 'pendakian', 'Alam'),
                      const SizedBox(width: 10),
                      _chip(c, 'budaya_seni', 'Ritual'),
                      const SizedBox(width: 10),
                      _chip(c, 'edukasi_durian', 'Kuliner'),
                      const SizedBox(width: 10),
                      _chip(c, 'trabas', 'Petualangan'),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // ── Package list ─────────────────────────────
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (c.error.isNotEmpty) {
                  return ErrorState(message: c.error.value, onRetry: c.fetch);
                }
                if (c.filteredPackages.isEmpty) {
                  return const Center(
                      child: Text('Belum ada paket.',
                          style: TextStyle(color: AppColors.outline)));
                }
                return RefreshIndicator(
                  onRefresh: c.fetch,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: c.filteredPackages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (_, i) {
                      final pkg = c.filteredPackages[i];
                      return _PackageCard(
                        package: pkg,
                        onEdit: () => _showEditSheet(context, c, pkg),
                        onDelete: () => _confirmDelete(c, pkg.id, pkg.name),
                        onPublish: () => _showEditSheet(context, c, pkg),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
      ),
      floatingActionButton: null,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _chip(AdminPackagesController c, String key, String label) {
    final active = c.selectedFilter.value == key;
    return GestureDetector(
      onTap: () => c.selectedFilter.value = key,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.outline,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, AdminPackagesController c, PackageModel pkg) {
    c.fillFormForEdit(pkg);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPackageSheet(c: c, pkg: pkg),
    );
  }

  void _confirmDelete(
      AdminPackagesController c, int id, String name) {
    Get.dialog(AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hapus Paket?'),
      content: Text(
          'Paket "$name" dan semua fotonya akan dihapus permanen.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.outline))),
        ElevatedButton(
          onPressed: () {
            Get.back();
            c.delete(id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Hapus'),
        ),
      ],
    ));
  }
}

// ── Package Card (UI lama) ─────────────────────────────────
class _PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;

  const _PackageCard({
    required this.package,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final isInactive = package.status == 'inactive';
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: AppColors.cardDecoration(radius: AppColors.radiusL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppColors.radiusL),
                  topRight: Radius.circular(AppColors.radiusL),
                ),
                child: AppNetworkImage(
                  url: package.coverImage,
                  width: double.infinity,
                  height: 180,
                ),
              ),
              // Price badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppColors.radiusXl),
                  ),
                  child: Text(
                    fmt.format(package.pricePerPerson),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Inactive overlay
              if (isInactive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppColors.radiusL),
                        topRight: Radius.circular(AppColors.radiusL),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'NONAKTIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Info ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppColors.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: AppColors.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppColors.spaceXs),
                Text(
                  package.description,
                  style: AppColors.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppColors.spaceM),
                Row(
                  children: [
                    _infoItem(Icons.group_outlined,
                        'Min. ${package.minPerson} orang'),
                    const SizedBox(width: AppColors.spaceL),
                    _infoItem(Icons.sell_outlined, package.categoryLabel),
                  ],
                ),
                const SizedBox(height: AppColors.spaceL),

                // ── Buttons ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isInactive ? onPublish : onEdit,
                        icon: Icon(
                          isInactive ? Icons.publish : Icons.edit_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          isInactive ? 'Publish' : 'Edit',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppColors.radiusM)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppColors.spaceM),
                    if (isInactive) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppColors.radiusS),
                        ),
                        child: IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.primary),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: AppColors.spaceS),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppColors.radiusS),
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        constraints: const BoxConstraints(),
                      ),
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

  Widget _infoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.outline),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.outline)),
      ],
    );
  }
}

// ── Edit Package Bottom Sheet ──────────────────────────────
class _EditPackageSheet extends StatelessWidget {
  final AdminPackagesController c;
  final PackageModel pkg;
  const _EditPackageSheet({required this.c, required this.pkg});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Edit Paket',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Foto cover
            _label('Foto Cover'),
            Obx(() {
              final file = c.coverImageFile.value;
              return GestureDetector(
                onTap: c.pickCoverImage,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: file != null
                      ? XFileImage(
                          xfile: file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 140)
                      : pkg.coverImage != null
                          ? Stack(fit: StackFit.expand, children: [
                              AppNetworkImage(
                                  url: pkg.coverImage,
                                  width: double.infinity,
                                  height: 140),
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: Icon(Icons.edit,
                                      color: Colors.white, size: 28),
                                ),
                              ),
                            ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5)),
                                const SizedBox(height: 6),
                                Text('Ketuk untuk pilih foto',
                                    style: TextStyle(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.6),
                                        fontSize: 12)),
                              ],
                            ),
                ),
              );
            }),
            const SizedBox(height: 14),

            _label('Nama Paket *'),
            _field(c.nameCtrl, 'Nama paket'),
            const SizedBox(height: 12),

            _label('Kategori'),
            Obx(() => DropdownButtonFormField<String>(
                  value: c.selectedCategory.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: c.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat['key'],
                            child: Text(cat['label']!),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedCategory.value = v!,
                )),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Harga / Orang (Rp) *'),
                    _field(c.priceCtrl, '75000',
                        type: TextInputType.number),
                  ])),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Min. Orang *'),
                    _field(c.minPeopleCtrl, '5',
                        type: TextInputType.number),
                  ])),
            ]),
            const SizedBox(height: 12),

            _label('Status'),
            Obx(() => DropdownButtonFormField<String>(
                  value: c.selectedStatus.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Aktif')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Nonaktif')),
                  ],
                  onChanged: (v) => c.selectedStatus.value = v!,
                )),
            const SizedBox(height: 12),

            _label('Deskripsi'),
            _field(c.descCtrl, 'Deskripsi paket...', maxLines: 3),
            const SizedBox(height: 12),

            _label('Syarat & Ketentuan'),
            _field(c.termsCtrl, 'Syarat dan ketentuan...', maxLines: 2),
            const SizedBox(height: 24),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.isSubmitting.value
                        ? null
                        : () => c.updatePackage(pkg.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: c.isSubmitting.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan Perubahan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppColors.spaceS),
        child: Text(text, style: AppColors.labelBold),
      );

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: AppColors.inputDecoration,
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
