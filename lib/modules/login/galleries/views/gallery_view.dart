import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/shared/colors.dart';
import '../../../../app/shared/widgets/network_image_widget.dart';
import '../../../../app/shared/widgets/error_state.dart';
import '../controllers/gallery_controller.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GalleryController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        title: const Text('Galeri Foto',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
        shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0))),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
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
        if (c.galleries.isEmpty) {
          return const Center(
              child: Text('Belum ada foto.', style: TextStyle(color: AppColors.outline)));
        }
        return RefreshIndicator(
          onRefresh: c.fetch,
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: c.galleries.length,
            itemBuilder: (_, i) {
              final g = c.galleries[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    url: g.imageUrl,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(c, g.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(GalleryController c, int id) {
    Get.dialog(AlertDialog(
      title: const Text('Hapus Foto?'),
      content: const Text('Foto ini akan dihapus permanen.'),
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
