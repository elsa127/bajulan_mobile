import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/bottom_nav.dart';
import '../../../app/shared/widgets/error_state.dart';
import '../../../app/data/models/booking_model.dart';
import '../controllers/booking_controller.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        title: const Text('Bookings',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
        shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0))),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (c.error.isNotEmpty) {
          return ErrorState(message: c.error.value, onRetry: c.fetch);
        }
        if (c.bookings.isEmpty) {
          return const Center(
              child: Text('Belum ada booking.',
                  style: TextStyle(color: AppColors.outline)));
        }
        return RefreshIndicator(
          onRefresh: c.fetch,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: c.bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _BookingCard(booking: c.bookings[i], fmt: fmt),
          ),
        );
      }),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final NumberFormat fmt;
  const _BookingCard({required this.booking, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(4, 4)),
          const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-4, -4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.guestName,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                if (booking.package != null)
                  Text(booking.package!.name,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                Text('#${booking.code}',
                    style: const TextStyle(color: AppColors.outline, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16)),
                child: Text(booking.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(fmt.format(booking.totalPrice),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text('${booking.totalPerson} orang',
                  style: const TextStyle(color: AppColors.outline, fontSize: 10)),
            ],
          ),
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
}
