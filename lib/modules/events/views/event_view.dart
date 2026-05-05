import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/network_image_widget.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/data/models/event_model.dart';
import '../controllers/event_controller.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Column(
        children: [
          _buildHeader(context, c),
          // Stats
          Obx(() => _buildStats(c)),
          const SizedBox(height: 12),
          // Search
          _buildSearch(c),
          const SizedBox(height: 8),
          // List
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
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy_outlined,
                          size: 56, color: AppColors.muted),
                      SizedBox(height: 12),
                      Text('Belum ada event.',
                          style: TextStyle(color: AppColors.outline)),
                    ],
                  ),
                ));
              }
              return RefreshIndicator(
                onRefresh: c.fetch,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: c.filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _EventCard(event: c.filtered[i], c: c),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, EventController c) {
    return Container(
      color: const Color(0xFFF5F0E8),
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
                  'Cultural Events',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Manage Bajulan's traditional festivities",
                  style: TextStyle(color: AppColors.outline, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddEventSheet(context, c),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create\nEvent',
                style: TextStyle(fontSize: 11, height: 1.2)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats ──────────────────────────────────────────────
  Widget _buildStats(EventController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _statCard('Active', c.activeCount.toString(),
                  AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard('Upcoming', c.upcomingCount.toString(),
                  AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.outline, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Search ─────────────────────────────────────────────
  Widget _buildSearch(EventController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          onChanged: (v) => c.searchQuery.value = v,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
            prefixIcon:
                Icon(Icons.search, color: AppColors.muted, size: 20),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
    );
  }

  // ── Add Event Bottom Sheet ─────────────────────────────
  void _showAddEventSheet(BuildContext context, EventController c) {
    c.clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(c: c),
    );
  }
}

// ── Event Card ─────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final EventModel event;
  final EventController c;
  const _EventCard({required this.event, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 160,
                child: event.imageUrl != null
                    ? AppNetworkImage(
                        url: event.imageUrl,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    : _imagePlaceholder(),
              ),
              // Action buttons
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    _actionBtn(Icons.edit_outlined,
                        () => _showEditSheet(context)),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.delete_outline,
                        () => _confirmDelete(context)),
                  ],
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package tag
                if (event.packageName.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.packageName.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                // Name
                Text(
                  event.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Date & Location
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(event.eventDate),
                      style: const TextStyle(
                          color: AppColors.outline, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                            color: AppColors.outline, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _statusBadge(event.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.secondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_outlined, color: Colors.white54, size: 48),
          const SizedBox(height: 8),
          Text(
            event.name,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    Color bg;
    switch (status) {
      case 'ongoing':
        color = Colors.green;
        bg = Colors.green.withValues(alpha: 0.1);
        break;
      case 'upcoming':
        color = AppColors.secondary;
        bg = AppColors.secondary.withValues(alpha: 0.1);
        break;
      case 'done':
        color = Colors.grey;
        bg = Colors.grey.withValues(alpha: 0.1);
        break;
      case 'cancelled':
        color = AppColors.error;
        bg = AppColors.error.withValues(alpha: 0.1);
        break;
      default:
        color = AppColors.outline;
        bg = AppColors.muted.withValues(alpha: 0.1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'ongoing': return 'Ongoing';
      case 'upcoming': return 'Upcoming';
      case 'done': return 'Done';
      case 'cancelled': return 'Cancelled';
      default: return s;
    }
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('d MMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return date;
    }
  }

  void _showEditSheet(BuildContext context) {
    c.fillFormForEdit(event);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(c: c, editId: event.id),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Text('Hapus Event?'),
      content: Text('"${event.name}" akan dihapus permanen.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.outline))),
        TextButton(
            onPressed: () {
              Get.back();
              c.delete(event.id);
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}

// ── Add/Edit Event Bottom Sheet ────────────────────────────
class _AddEventSheet extends StatelessWidget {
  final EventController c;
  final int? editId; // null = tambah, ada nilai = edit
  const _AddEventSheet({required this.c, this.editId});

  bool get isEdit => editId != null;

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
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(isEdit ? 'Edit Event' : 'Tambah Event',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _label('Nama Event *'),
            _field(c.nameCtrl, 'Contoh: Bersih Desa Festival'),
            const SizedBox(height: 14),

            _label('Deskripsi'),
            _field(c.descCtrl, 'Deskripsi event...', maxLines: 3),
            const SizedBox(height: 14),

            _label('Lokasi'),
            _field(c.locationCtrl, 'Contoh: Balai Adat Bajulan'),
            const SizedBox(height: 14),

            // Image picker
            _label('Foto Event (opsional)'),
            Obx(() => GestureDetector(
                  onTap: c.pickImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.muted.withValues(alpha: 0.5)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: c.selectedImage.value != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(c.selectedImage.value!.path),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () => c.selectedImage.value = null,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.muted, size: 32),
                              SizedBox(height: 6),
                              Text('Pilih foto dari galeri',
                                  style: TextStyle(
                                      color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                  ),
                )),
            const SizedBox(height: 14),

            _label('Tanggal Event *'),
            Obx(() => GestureDetector(
                  onTap: () => c.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          c.selectedDate.value != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(c.selectedDate.value!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color: c.selectedDate.value != null
                                ? AppColors.onSurface
                                : AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 14),

            _label('Status'),
            Obx(() => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    value: c.selectedStatus.value,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                      DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                      DropdownMenuItem(value: 'done', child: Text('Done')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (v) => c.selectedStatus.value = v!,
                  ),
                )),
            const SizedBox(height: 24),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.isSubmitting.value
                        ? null
                        : () {
                            if (isEdit) {
                              c.updateEvent(editId!);
                            } else {
                              c.store();
                            }
                          },
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
                        : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Event',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface)),
    );
  }

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
          hintStyle:
              const TextStyle(color: AppColors.muted, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
