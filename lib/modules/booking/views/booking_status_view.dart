import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/booking_status_controller.dart';

class BookingStatusView extends StatelessWidget {
  const BookingStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingStatusController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
        title: const Text('Status Booking',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan kode booking (KAB-...)',
                        hintStyle: TextStyle(color: AppColors.outline, fontSize: 13),
                        prefixIcon: Icon(Icons.confirmation_number_outlined,
                            color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Obx(() => ElevatedButton(
                          onPressed: c.isLoading.value
                              ? null
                              : () => c.fetchStatus(c.codeCtrl.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: c.isLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Cek'),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              if (c.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (c.error.isNotEmpty) {
                return _errorCard(c.error.value);
              }
              if (c.booking.value == null) {
                return _emptyState();
              }
              return _buildBookingCard(c);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingStatusController c) {
    final b = c.booking.value!;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final statusColor = _statusColor(b.status);
    final statusIcon = _statusIcon(b.status);

    return Column(
      children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(statusIcon, size: 48, color: statusColor),
              const SizedBox(height: 8),
              Text(b.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 4),
              Text(_statusDesc(b.status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.outline, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detail card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kode Booking',
                      style: TextStyle(color: AppColors.outline, fontSize: 12)),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: b.code));
                      Get.snackbar('Disalin', 'Kode booking disalin.',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: Row(
                      children: [
                        Text(b.code,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 14, color: AppColors.outline),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _row('Nama', b.guestName),
              _row('No. HP', b.guestPhone),
              if (b.package != null) _row('Paket', b.package!.name),
              _row('Tanggal Kunjungan', b.visitDate),
              _row('Jumlah Orang', '${b.totalPerson} orang'),
              _row('Total Pembayaran', fmt.format(b.totalPrice)),
              if (b.notes != null && b.notes!.isNotEmpty) _row('Catatan', b.notes!),
            ],
          ),
        ),

        // Tombol bayar jika masih pending dan ada snap token
        if (b.status.toLowerCase() == 'pending' && b.snapToken != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.payment, arguments: {
                'booking_code': b.code,
                'snap_token': b.snapToken,
              }),
              icon: const Icon(Icons.payment),
              label: const Text('Lanjutkan Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: AppColors.outline, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.confirmation_number_outlined, size: 56, color: AppColors.muted),
          SizedBox(height: 12),
          Text('Masukkan kode booking untuk melihat status.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.outline, fontSize: 13)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'cancelled':
      case 'failed':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _statusDesc(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Pembayaran berhasil. Sampai jumpa di Bajulan!';
      case 'confirmed':
        return 'Booking dikonfirmasi oleh admin.';
      case 'pending':
        return 'Menunggu pembayaran. Segera selesaikan sebelum expired.';
      case 'cancelled':
        return 'Booking dibatalkan.';
      case 'failed':
        return 'Pembayaran gagal. Silakan buat booking baru.';
      default:
        return '';
    }
  }
}
