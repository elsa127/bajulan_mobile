import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/data/models/package_model.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/network_image_widget.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;

  const PackageCard({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final isUnpublished = package.status == PackageStatus.unpublished;

    // Formatting price to 'k' format for badge e.g. IDR 450k
    String priceBadge = 'IDR ${(package.pricePerPerson / 1000).toStringAsFixed(0)}k';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Part: Image with Badge & Overlay
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

              // Price Badge (Kanan Atas)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priceBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Status Overlay (Jika Unpublished)
              if (isUnpublished)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
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

          // Bottom Part: Info Content
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info Row (Waktu & Group)
                Row(
                  children: [
                    _infoItem(Icons.access_time_filled, package.duration),
                    const SizedBox(width: 16),
                    _infoItem(Icons.group_rounded, 'Max ${package.maxPeople}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Button Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        // Jika unpublished klik tombol utama panggil onPublish, jika published panggil onEdit
                        onPressed: isUnpublished ? onPublish : onEdit,
                        icon: Icon(
                          isUnpublished ? Icons.publish : Icons.edit_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          isUnpublished ? 'Publish' : 'Edit',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Edit Tambahan (Pencil) hanya jika STATUS UNPUBLISHED
                    if (isUnpublished) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // Abu-abu muda
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: onEdit, // Tetap bisa edit meskipun belum publish
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF2D3A30)),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Tombol Delete (Tetap Ada)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3A30),
          ),
        ),
      ],
    );
  }
}