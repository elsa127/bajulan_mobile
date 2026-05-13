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
          Obx(() => _buildStats(c)),
          const SizedBox(height: 12),
          _buildSearch(c),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary));
              }
              if (c.error.isNotEmpty) {
                return ErrorState(
                    message: c.error.value, onRetry: c.fetch);
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
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: c.filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                  itemBuilder: (_, i) =>
                      _EventCard(event: c.filtered[i], c: c),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

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
                Text('Event Budaya',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Kelola event Kampung Adat Bajulan',
                    style: TextStyle(
                        color: AppColors.outline, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showFormSheet(context, c),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah\nEvent',
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
    );
  }

  Widget _buildStats(EventController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _statCard(
                  'Berlangsung', c.activeCount.toString(), AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard(
                  'Akan Datang', c.upcomingCount.toString(), AppColors.secondary)),
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
              style:
                  const TextStyle(color: AppColors.outline, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

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
            hintText: 'Cari event...',
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

  void _showFormSheet(BuildContext context, EventController c,
      {EventModel? editEvent}) {
    if (editEvent != null) {
      c.fillFormForEdit(editEvent);
    } else {
      c.clearForm();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _EventFormSheet(c: c, editEvent: editEvent),
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
          // Image (jika ada)
          if (event.imageUrl != null)
            AppNetworkImage(
              url: event.imageUrl,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(event.name,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                    _statusBadge(event.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(_formatDate(event.eventDate),
                        style: const TextStyle(
                            color: AppColors.outline, fontSize: 12)),
                    if (event.startTime != null && event.startTime!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          size: 13, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(
                        event.startTime!.length >= 5
                            ? event.startTime!.substring(0, 5)
                            : event.startTime!,
                        style: const TextStyle(
                            color: AppColors.outline, fontSize: 12),
                      ),
                      if (event.endTime != null && event.endTime!.isNotEmpty)
                        Text(
                          ' – ${event.endTime!.length >= 5 ? event.endTime!.substring(0, 5) : event.endTime!}',
                          style: const TextStyle(
                              color: AppColors.outline, fontSize: 12),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event.location,
                          style: const TextStyle(
                              color: AppColors.outline, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(event.description,
                      style: const TextStyle(
                          color: AppColors.outline, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditSheet(context),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: const Text('Hapus',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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

  Widget _statusBadge(String status) {
    Color color;
    Color bg;
    String label;
    switch (status) {
      case 'ongoing':
        color = Colors.green;
        bg = Colors.green.withValues(alpha: 0.1);
        label = 'Berlangsung';
        break;
      case 'upcoming':
        color = AppColors.secondary;
        bg = AppColors.secondary.withValues(alpha: 0.1);
        label = 'Akan Datang';
        break;
      case 'done':
        color = Colors.grey;
        bg = Colors.grey.withValues(alpha: 0.1);
        label = 'Selesai';
        break;
      case 'cancelled':
        color = AppColors.error;
        bg = AppColors.error.withValues(alpha: 0.1);
        label = 'Dibatalkan';
        break;
      default:
        color = AppColors.outline;
        bg = AppColors.muted.withValues(alpha: 0.1);
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
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
      builder: (_) => _EventFormSheet(c: c, editEvent: event),
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
        ElevatedButton(
          onPressed: () {
            Get.back();
            c.delete(event.id);
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

// ── Event Form Bottom Sheet ────────────────────────────────
class _EventFormSheet extends StatelessWidget {
  final EventController c;
  final EventModel? editEvent;
  const _EventFormSheet({required this.c, this.editEvent});

  bool get isEdit => editEvent != null;

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
                    borderRadius: BorderRadius.circular(2)),
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

            // ── Jam Mulai & Selesai ────────────────────────
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Jam Mulai'),
                  GestureDetector(
                    onTap: () => c.pickTime(context, isStart: true),
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.access_time,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          c.selectedStartTime.value != null
                              ? c.startTimeCtrl.text
                              : 'Pilih jam',
                          style: TextStyle(
                            color: c.selectedStartTime.value != null
                                ? AppColors.onSurface
                                : AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                    )),
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Jam Selesai'),
                  GestureDetector(
                    onTap: () => c.pickTime(context, isStart: false),
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.access_time_filled,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          c.selectedEndTime.value != null
                              ? c.endTimeCtrl.text
                              : 'Pilih jam',
                          style: TextStyle(
                            color: c.selectedEndTime.value != null
                                ? AppColors.onSurface
                                : AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                    )),
                  ),
                ],
              )),
            ]),
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
                      DropdownMenuItem(
                          value: 'upcoming', child: Text('Akan Datang')),
                      DropdownMenuItem(
                          value: 'ongoing', child: Text('Berlangsung')),
                      DropdownMenuItem(
                          value: 'done', child: Text('Selesai')),
                      DropdownMenuItem(
                          value: 'cancelled', child: Text('Dibatalkan')),
                    ],
                    onChanged: (v) => c.selectedStatus.value = v!,
                  ),
                )),
            const SizedBox(height: 14),

            // ── Pilih Paket (opsional) ─────────────────────
            _label('Paket Wisata (opsional)'),
            Obx(() {
              if (c.isLoadingPackages.value) {
                return Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F2ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<int?>(
                  value: c.selectedPackageId.value,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  hint: const Text('Tidak terhubung ke paket',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tidak terhubung ke paket',
                          style: TextStyle(color: AppColors.muted)),
                    ),
                    ...c.packages.map((pkg) => DropdownMenuItem<int?>(
                          value: pkg.id,
                          child: Text(
                            pkg.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (v) => c.selectedPackageId.value = v,
                ),
              );
            }),
            const SizedBox(height: 24),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.isSubmitting.value
                        ? null
                        : () => isEdit
                            ? c.updateEvent(editEvent!.id)
                            : c.store(),
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
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Simpan Event',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
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
