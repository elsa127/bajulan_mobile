import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/shared/colors.dart';
import '../../../../app/shared/widgets/network_image_widget.dart';
import '../../../../app/shared/widgets/error_state.dart';
import '../../../../app/shared/widgets/bottom_nav.dart';
import '../controllers/gallery_controller.dart';
import '../../../../app/data/models/gallery_model.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GalleryController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Column(
        children: [
          _buildHeader(context, c),
          _buildFilterChips(c),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (c.error.isNotEmpty) {
                return ErrorState(message: c.error.value, onRetry: c.fetch);
              }
              if (c.filtered.isEmpty) {
                return _buildEmptyState(context, c);
              }
              return RefreshIndicator(
                onRefresh: c.fetch,
                color: AppColors.primary,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: c.filtered.length,
                  itemBuilder: (_, i) =>
                      _GalleryItem(gallery: c.filtered[i], c: c),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton(
            onPressed: c.isSubmitting.value
                ? null
                : () {
                    c.clearForm();
                    _showAddSheet(context, c);
                  },
            backgroundColor: AppColors.primary,
            child: c.isSubmitting.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.add_photo_alternate_outlined,
                    color: Colors.white),
          )),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 4),
    );
  }

  Widget _buildHeader(BuildContext context, GalleryController c) {
    return Container(
      color: const Color(0xFFF5F0E8),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Galeri Dokumentasi',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Foto kegiatan Kampung Adat Bajulan',
                    style: TextStyle(color: AppColors.outline, fontSize: 12)),
              ],
            ),
          ),
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${c.galleries.length} foto',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChips(GalleryController c) {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'kampung', 'label': 'Kampung Adat'},
      {'key': 'budaya', 'label': 'Budaya'},
      {'key': 'alam', 'label': 'Alam'},
      {'key': 'kuliner', 'label': 'Kuliner'},
      {'key': 'event', 'label': 'Event'},
      {'key': 'lainnya', 'label': 'Lainnya'},
    ];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          return Obx(() {
            final active = c.selectedFilter.value == f['key'];
            return GestureDetector(
              onTap: () => c.selectedFilter.value = f['key']!,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? AppColors.primary : AppColors.muted),
                ),
                child: Text(f['label']!,
                    style: TextStyle(
                        color: active ? Colors.white : AppColors.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, GalleryController c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo_library_outlined,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada foto',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 6),
          const Text('Tambahkan foto dokumentasi kegiatan',
              style: TextStyle(color: AppColors.outline, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              c.clearForm();
              _showAddSheet(context, c);
            },
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Tambah Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, GalleryController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGallerySheet(c: c),
    );
  }
}

// ── Gallery Item ───────────────────────────────────────────
class _GalleryItem extends StatelessWidget {
  final GalleryModel gallery;
  final GalleryController c;
  const _GalleryItem({required this.gallery, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      onLongPress: () => _showOptionsMenu(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppNetworkImage(url: gallery.imageUrl, fit: BoxFit.cover),
          ),
          if (gallery.isFeatured)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.amber, shape: BoxShape.circle),
                child: const Icon(Icons.star, color: Colors.white, size: 10),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                color: Colors.black45,
                child: Text(
                  gallery.title.isNotEmpty
                      ? gallery.title
                      : gallery.categoryLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (_, __, ___) => _FullscreenPhoto(gallery: gallery),
    ));
  }

  void _showOptionsMenu(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Foto'),
              subtitle: const Text('Ubah judul, kategori, atau gambar'),
              onTap: () {
                Get.back();
                c.populateForm(gallery);
                // Show edit sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _AddGallerySheet(c: c),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.secondary),
              title: const Text('Debug Info'),
              subtitle: Text(
                'URL: ${gallery.imageUrl}',
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Image URL',
                  gallery.imageUrl,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 5),
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Hapus Foto'),
              onTap: () {
                Get.back();
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Text('Hapus Foto?'),
      content: Text(
          '"${gallery.title.isNotEmpty ? gallery.title : 'Foto ini'}" akan dihapus permanen.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.outline))),
        ElevatedButton(
          onPressed: () {
            Get.back();
            c.delete(gallery.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
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

// ── Add Gallery Bottom Sheet ───────────────────────────────
class _AddGallerySheet extends StatelessWidget {
  final GalleryController c;
  const _AddGallerySheet({required this.c});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                    c.isEditMode.value ? 'Edit Foto' : 'Tambah Foto',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
                Obx(() => c.selectedImages.isNotEmpty && !c.isEditMode.value
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${c.selectedImages.length} foto dipilih',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 20),

            // ── Area Pilih Foto ────────────────────
            Obx(() => !c.isEditMode.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Foto * (bisa pilih banyak)'),
                      _buildImagePickerWidget(context, c),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Ganti Foto (opsional)'),
                      _buildImagePickerWidget(context, c),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: Text(
                          'Kosongkan jika tidak ingin mengganti foto',
                          style: TextStyle(
                              color: AppColors.outline, fontSize: 11),
                        ),
                      ),
                    ],
                  )),
            const SizedBox(height: 16),

            // ── Judul ──────────────────────────────
            _label('Judul *'),
            _field(c.titleCtrl, 'Contoh: Upacara Bersih Desa 2024'),
            Obx(() => c.selectedImages.length > 1
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, left: 2),
                    child: Text(
                      'Judul akan diberi nomor otomatis untuk ${c.selectedImages.length} foto',
                      style: const TextStyle(
                          color: AppColors.outline, fontSize: 11),
                    ),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 14),

            // ── Keterangan ─────────────────────────
            _label('Keterangan (opsional)'),
            _field(c.captionCtrl, 'Deskripsi singkat...', maxLines: 2),
            const SizedBox(height: 14),

            // ── Kategori ───────────────────────────
            _label('Kategori *'),
            Obx(() => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    value: c.selectedCategory.value,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: c.categories
                        .map((cat) => DropdownMenuItem(
                              value: cat['key'],
                              child: Text(cat['label']!),
                            ))
                        .toList(),
                    onChanged: (v) => c.selectedCategory.value = v!,
                  ),
                )),
            const SizedBox(height: 14),

            // ── Featured ───────────────────────────
            Obx(() => GestureDetector(
                  onTap: () => c.isFeatured.value = !c.isFeatured.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          c.isFeatured.value
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: c.isFeatured.value
                              ? Colors.amber
                              : AppColors.muted,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Foto Unggulan',
                                  style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              Text(
                                c.selectedImages.length > 1
                                    ? 'Hanya foto pertama yang dijadikan unggulan'
                                    : 'Tampilkan di halaman utama publik',
                                style: const TextStyle(
                                    color: AppColors.outline, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: c.isFeatured.value,
                          onChanged: (v) => c.isFeatured.value = v,
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // ── Progress bar ───────────────────────
            Obx(() {
              if (!c.isSubmitting.value || c.uploadTotal.value == 0) {
                return const SizedBox.shrink();
              }
              final progress =
                  c.uploadProgress.value / c.uploadTotal.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mengunggah ${c.uploadProgress.value} dari ${c.uploadTotal.value} foto...',
                        style: const TextStyle(
                            color: AppColors.outline, fontSize: 12),
                      ),
                      Text('${(progress * 100).toInt()}%',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // ── Tombol Simpan ──────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.isSubmitting.value
                        ? null
                        : (c.isEditMode.value ? c.updateGallery : c.store),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: c.isSubmitting.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Obx(() => Text(
                              c.isEditMode.value
                                  ? 'Perbarui Foto'
                                  : (c.selectedImages.length > 1
                                      ? 'Unggah ${c.selectedImages.length} Foto'
                                      : 'Simpan Foto'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            )),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
              ),
              title: const Text('Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Bisa pilih banyak foto sekaligus'),
              onTap: () {
                Get.back();
                c.pickImages();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.secondary),
              ),
              title: const Text('Ambil dari Kamera',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Foto langsung dari kamera'),
              onTap: () {
                Get.back();
                c.pickFromCamera();
              },
            ),
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
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF5F2ED),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
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

  Widget _buildImagePickerWidget(BuildContext context, GalleryController c) {
    return Obx(() {
      final images = c.selectedImages;
      return Column(
        children: [
          if (images.isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == images.length) {
                    return GestureDetector(
                      onTap: () => _showSourceSheet(context),
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.muted.withValues(alpha: 0.5)),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primary, size: 28),
                            SizedBox(height: 4),
                            Text('Tambah',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(images[i].path),
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => c.removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 13),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            GestureDetector(
              onTap: () => _showSourceSheet(context),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F2ED),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.muted.withValues(alpha: 0.5)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.muted, size: 40),
                    SizedBox(height: 8),
                    Text('Ketuk untuk pilih foto',
                        style:
                            TextStyle(color: AppColors.muted, fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Bisa pilih banyak sekaligus',
                        style:
                            TextStyle(color: AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: c.pickImages,
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Galeri', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: c.pickFromCamera,
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Kamera', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ── Fullscreen Photo Viewer ────────────────────────────────
class _FullscreenPhoto extends StatelessWidget {
  final GalleryModel gallery;
  const _FullscreenPhoto({required this.gallery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: AppNetworkImage(
                url: gallery.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (gallery.title.isNotEmpty || gallery.caption != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (gallery.title.isNotEmpty)
                      Text(gallery.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    if (gallery.caption != null) ...[
                      const SizedBox(height: 4),
                      Text(gallery.caption!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                    if (gallery.categoryLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(gallery.categoryLabel,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
