import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none,
                          color: Color(0xFF2D3A30)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDE8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (v) => c.searchQuery.value = v,
                  decoration: const InputDecoration(
                    hintText: 'Search packages...',
                    hintStyle:
                        TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    icon: Icon(Icons.search,
                        color: Color(0xFF9CA3AF), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.adminAddPackage),
        backgroundColor: const Color(0xFF2D3A30),
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _chip(AdminPackagesController c, String key, String label) {
    final active = c.selectedFilter.value == key;
    return GestureDetector(
      onTap: () => c.selectedFilter.value = key,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF2D3A30)
              : const Color(0xFFEEEAE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF6B7280),
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
    final priceK =
        'IDR ${(package.pricePerPerson / 1000).toStringAsFixed(0)}k';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(priceK,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              // Inactive overlay
              if (isInactive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'UNPUBLISHED',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A30),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  package.description,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoItem(Icons.access_time_filled, '1 Hari'),
                    const SizedBox(width: 16),
                    _infoItem(Icons.group_rounded,
                        'Min ${package.minPerson}'),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Buttons ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isInactive ? onPublish : onEdit,
                        icon: Icon(
                          isInactive
                              ? Icons.publish
                              : Icons.edit_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          isInactive ? 'Publish' : 'Edit',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isInactive) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined,
                              color: Color(0xFF2D3A30)),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline,
                            color: Color(0xFFB91C1C)),
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
        Icon(icon, size: 16, color: const Color(0xFF2D3A30)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3A30))),
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
                    color: const Color(0xFFF0EDE9),
                    borderRadius: BorderRadius.circular(12),
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
                    fillColor: const Color(0xFFF0EDE9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    fillColor: const Color(0xFFF0EDE9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface)),
      );

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF0EDE9),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.muted, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
