import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/data/models/booking_model.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/booking_controller.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
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
              final list = c.filtered;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 56, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text(
                        c.selectedFilter.value == 'semua'
                            ? 'Belum ada pemesanan.'
                            : 'Tidak ada pemesanan dengan status ini.',
                        style: const TextStyle(color: AppColors.outline),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c.fetch,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _BookingCard(booking: list[i], fmt: fmt),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, BookingController c) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 12),
      child: Obx(() {
        final fmt = NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        final monthFmt = DateFormat('MMMM yyyy', 'id_ID');

        final paid = c.bookings.where((b) => b.status == 'paid' || b.status == 'confirmed').length;
        final pending = c.bookings.where((b) => b.status == 'pending').length;
        final cancelled = c.bookings.where((b) => b.status == 'cancelled').length;

        // Pendapatan dari filtered (sesuai bulan & status yang dipilih)
        final revenue = c.filteredRevenue;
        final selectedMonth = c.selectedMonth.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Pemesanan',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola semua pemesanan wisata',
                      style: TextStyle(color: AppColors.outline, fontSize: 12),
                    ),
                  ],
                ),
                // Tombol filter bulan
                GestureDetector(
                  onTap: () => _showMonthPicker(context, c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedMonth != null
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 14,
                            color: selectedMonth != null
                                ? Colors.white
                                : AppColors.outline),
                        const SizedBox(width: 4),
                        Text(
                          selectedMonth != null
                              ? monthFmt.format(selectedMonth)
                              : 'Semua Bulan',
                          style: TextStyle(
                            color: selectedMonth != null
                                ? Colors.white
                                : AppColors.outline,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (selectedMonth != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => c.selectMonth(null),
                            child: const Icon(Icons.close,
                                size: 12, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Total pendapatan lunas (sesuai filter bulan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    selectedMonth != null
                        ? 'Pendapatan ${monthFmt.format(selectedMonth)}: '
                        : 'Total pendapatan lunas: ',
                    style: const TextStyle(
                        color: AppColors.outline, fontSize: 12),
                  ),
                  Text(
                    fmt.format(revenue),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Stat chips
            Row(
              children: [
                _statChip('Lunas', paid.toString(), AppColors.success),
                const SizedBox(width: 8),
                _statChip('Menunggu', pending.toString(), Colors.orange),
                const SizedBox(width: 8),
                _statChip('Batal', cancelled.toString(), AppColors.error),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _showMonthPicker(BuildContext context, BookingController c) {
    final months = c.availableMonths;
    if (months.isEmpty) {
      Get.snackbar('Info', 'Belum ada data booking.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final monthFmt = DateFormat('MMMM yyyy', 'id_ID');
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Text('Filter Bulan',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Opsi semua bulan
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.outline),
              title: const Text('Semua Bulan'),
              trailing: c.selectedMonth.value == null
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                c.selectMonth(null);
                Get.back();
              },
            ),
            const Divider(),
            ...months.map((m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month_outlined,
                      color: AppColors.secondary),
                  title: Text(monthFmt.format(m)),
                  trailing: c.selectedMonth.value?.year == m.year &&
                          c.selectedMonth.value?.month == m.month
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    c.selectMonth(m);
                    Get.back();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
        ],
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────
  Widget _buildFilterChips(BookingController c) {
    final labels = {
      'semua': 'Semua',
      'paid': 'Lunas',
      'pending': 'Menunggu',
      'cancelled': 'Dibatalkan',
    };
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: labels.entries.map((e) {
          return Obx(() {
            final active = c.selectedFilter.value == e.key;
            return GestureDetector(
              onTap: () => c.selectedFilter.value = e.key,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? AppColors.primary : AppColors.muted),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}

// ── Booking Card ───────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final NumberFormat fmt;
  const _BookingCard({required this.booking, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.adminBookingDetail,
        arguments: {'id': booking.id},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris atas: nama + status ──────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.guestName,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Nama paket ─────────────────────────────
            if (booking.package != null)
              Text(
                booking.package!.name,
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 10),

            // ── Baris bawah: tanggal + harga ───────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(booking.visitDate),
                      style: const TextStyle(
                          color: AppColors.outline, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  fmt.format(booking.totalPrice),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled':
      case 'failed': return Colors.red;
      case 'expired': return Colors.grey;
      default: return AppColors.outline;
    }
  }
}
