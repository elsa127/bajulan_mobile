import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/shared/widgets/network_image_widget.dart';
import '../controllers/booking_detail_controller.dart';
import '../../../app/data/models/booking_model.dart';

class BookingDetailView extends StatelessWidget {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingDetailController>();
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Obx(() {
        // ── Loading ──────────────────────────────────
        if (c.isLoading.value) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F0E8),
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // ── Error ────────────────────────────────────
        if (c.error.isNotEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F0E8),
            appBar: _buildAppBar(null),
            body: ErrorState(
              message: c.error.value,
              onRetry: () {
                final id = Get.arguments?['id'] as int?;
                if (id != null) c.fetch(id);
              },
            ),
          );
        }

        final b = c.booking.value!;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F0E8),
          body: CustomScrollView(
            slivers: [
              // ── AppBar ────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFF5F0E8),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () => Get.back(),
                ),
                title: const Text(
                  'Detail Transaksi',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: AppColors.primary, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: b.code));
                      Get.snackbar('Disalin', 'Kode booking disalin.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white);
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Transaction ID Card ──────────
                      _TransactionIdCard(booking: b),
                      const SizedBox(height: 16),

                      // ── Booking Info Card ────────────
                      _BookingInfoCard(booking: b, fmt: fmt),
                      const SizedBox(height: 16),

                      // ── Revenue Breakdown ────────────
                      _RevenueCard(booking: b, fmt: fmt),
                      const SizedBox(height: 16),

                      // ── Customer Details ─────────────
                      _CustomerCard(booking: b),
                      const SizedBox(height: 16),

                      // ── Payment Log ──────────────────
                      if (b.payment != null) ...[
                        _PaymentLogCard(payment: b.payment!),
                        const SizedBox(height: 16),
                      ],

                      // ── Catatan ──────────────────────
                      if (b.notes != null && b.notes!.isNotEmpty) ...[
                        _NotesCard(notes: b.notes!),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BookingModel? b) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F0E8),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Get.back(),
      ),
      title: const Text('Detail Transaksi',
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18)),
    );
  }
}

// ── Transaction ID Card ────────────────────────────────────
class _TransactionIdCard extends StatelessWidget {
  final BookingModel booking;
  const _TransactionIdCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ID TRANSAKSI',
                style: TextStyle(
                    color: AppColors.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      booking.statusLabel.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: booking.code));
              Get.snackbar('Disalin', 'Kode booking disalin.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white);
            },
            child: Row(
              children: [
                Text(
                  '#${booking.code}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy, size: 14, color: AppColors.outline),
              ],
            ),
          ),
          if (booking.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Diproses pada ${_formatDateTime(booking.createdAt!)}',
              style: const TextStyle(color: AppColors.outline, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled':
      case 'failed': return Colors.red;
      case 'expired': return Colors.grey;
      default: return AppColors.outline;
    }
  }

  String _formatDateTime(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      return DateFormat("d MMM yyyy '•' HH:mm 'WIB'", 'id_ID').format(d);
    } catch (_) {
      return dt;
    }
  }
}

// ── Booking Info Card ──────────────────────────────────────
class _BookingInfoCard extends StatelessWidget {
  final BookingModel booking;
  final NumberFormat fmt;
  const _BookingInfoCard({required this.booking, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kiri: info paket & tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                if (booking.package != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Paket Wisata',
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.package!.name,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.outline),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(booking.visitDate),
                      style: const TextStyle(
                          color: AppColors.outline, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Kanan: jumlah orang + gambar paket
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (booking.package?.coverImage != null)
                AppNetworkImage(
                  url: booking.package!.coverImage,
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(12),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.temple_hindu,
                      color: AppColors.primary, size: 28),
                ),
              const SizedBox(height: 6),
              Text(
                booking.totalPerson.toString().padLeft(2, '0'),
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              const Text('Tamu',
                  style: TextStyle(color: AppColors.outline, fontSize: 11)),
            ],
          ),
        ],
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
}

// ── Revenue Breakdown ──────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  final BookingModel booking;
  final NumberFormat fmt;
  const _RevenueCard({required this.booking, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final pricePerPerson = booking.totalPerson > 0
        ? (booking.totalPrice / booking.totalPerson).round()
        : booking.totalPrice;
    final baseTotal = pricePerPerson * booking.totalPerson;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'RINCIAN PEMBAYARAN',
            style: TextStyle(
                color: AppColors.outline,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              // Baris harga dasar
              _revenueRow(
                '${booking.totalPerson} tamu × ${fmt.format(pricePerPerson)}',
                fmt.format(baseTotal),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16,
                  color: Color(0xFFF0EDE9)),

              // Total row — dark background
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL PEMBAYARAN',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5),
                    ),
                    Text(
                      fmt.format(booking.totalPrice),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _revenueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.onSurface, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Customer Details ───────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final BookingModel booking;
  const _CustomerCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'DATA PEMESAN',
            style: TextStyle(
                color: AppColors.outline,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              // Nama + email
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.guestName,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          if (booking.guestEmail != null &&
                              booking.guestEmail!.isNotEmpty)
                            Text(
                              booking.guestEmail!,
                              style: const TextStyle(
                                  color: AppColors.outline, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0EDE9)),

              // No HP
              _detailRow(
                icon: Icons.phone_outlined,
                label: 'No. HP',
                value: booking.guestPhone,
              ),

              // Jumlah orang
              const Divider(height: 1, indent: 16, endIndent: 16,
                  color: Color(0xFFF0EDE9)),
              _detailRow(
                icon: Icons.group_outlined,
                label: 'Jumlah Tamu',
                value: '${booking.totalPerson} orang',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
      {required IconData icon,
      required String label,
      required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.outline),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.outline, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Payment Log ────────────────────────────────────────────
class _PaymentLogCard extends StatelessWidget {
  final PaymentInfo payment;
  const _PaymentLogCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isPaid = payment.status?.toLowerCase() == 'settlement' ||
        payment.status?.toLowerCase() == 'capture' ||
        payment.status?.toLowerCase() == 'paid';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'LOG PEMBAYARAN',
            style: TextStyle(
                color: AppColors.outline,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              // Icon metode pembayaran
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _methodLabel(payment.method),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    if (payment.transactionId != null)
                      Text(
                        payment.transactionId!,
                        style: const TextStyle(
                            color: AppColors.outline, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (payment.amount != null)
                      Text(
                        fmt.format(payment.amount),
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    if (payment.paidAt != null)
                      Text(
                        _formatDateTime(payment.paidAt!),
                        style: const TextStyle(
                            color: AppColors.outline, fontSize: 11),
                      ),
                  ],
                ),
              ),
              // Status icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_rounded : Icons.hourglass_empty_rounded,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _methodLabel(String? method) {
    if (method == null) return 'Pembayaran Online';
    switch (method.toLowerCase()) {
      case 'bank_transfer': return 'Transfer Bank';
      case 'credit_card': return 'Kartu Kredit';
      case 'gopay': return 'GoPay';
      case 'shopeepay': return 'ShopeePay';
      case 'qris': return 'QRIS';
      case 'cstore': return 'Minimarket';
      default: return method.toUpperCase();
    }
  }

  String _formatDateTime(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      return DateFormat("d MMM yyyy, HH:mm 'WIB'", 'id_ID').format(d);
    } catch (_) {
      return dt;
    }
  }
}

// ── Notes Card ─────────────────────────────────────────────
class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sticky_note_2_outlined,
                  size: 16, color: AppColors.secondary),
              SizedBox(width: 6),
              Text(
                'Catatan',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notes,
            style: const TextStyle(
                color: AppColors.onSurface, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
