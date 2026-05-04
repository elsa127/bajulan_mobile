import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/shared/colors.dart';
import '../../../app/shared/widgets/network_image_widget.dart';
import '../controllers/booking_form_controller.dart';

class BookingFormView extends StatelessWidget {
  const BookingFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingFormController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Form Pemesanan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (c.isLoadingPackage.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package summary card
              if (c.package.value != null) _buildPackageSummary(c),
              const SizedBox(height: 24),

              _label('Nama Lengkap *'),
              _field(c.nameCtrl, 'Masukkan nama lengkap', Icons.person_outline),
              const SizedBox(height: 16),

              _label('Nomor HP *'),
              _field(c.phoneCtrl, '08xxxxxxxxxx', Icons.phone_outlined,
                  type: TextInputType.phone),
              const SizedBox(height: 16),

              _label('Email (opsional)'),
              _field(c.emailCtrl, 'email@contoh.com', Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _label('Tanggal Kunjungan *'),
              Obx(() => GestureDetector(
                    onTap: () => c.pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EDE9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            c.visitDate.value != null
                                ? DateFormat('dd MMMM yyyy', 'id_ID')
                                    .format(c.visitDate.value!)
                                : 'Pilih tanggal kunjungan',
                            style: TextStyle(
                              color: c.visitDate.value != null
                                  ? AppColors.onSurface
                                  : AppColors.outline,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              _label('Jumlah Orang *'),
              _field(c.personCtrl, '1', Icons.group_outlined,
                  type: TextInputType.number),
              if (c.package.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Minimal ${c.package.value!.minPerson} orang',
                    style: const TextStyle(color: AppColors.outline, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 16),

              _label('Catatan (opsional)'),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: c.notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Permintaan khusus, alergi, dll.',
                    hintStyle: TextStyle(color: AppColors.outline, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Total estimate
              Obx(() {
                final persons = c.personCount.value;
                final price = c.package.value?.pricePerPerson ?? 0;
                final total = persons * price;
                final fmt =
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimasi Total',
                          style: TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                      Text(fmt.format(total),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: c.isSubmitting.value ? null : c.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: c.isSubmitting.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Lanjut ke Pembayaran',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  )),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPackageSummary(BookingFormController c) {
    final pkg = c.package.value!;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(14),
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
          AppNetworkImage(
            url: pkg.coverImage,
            width: 70,
            height: 70,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.name,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${fmt.format(pkg.pricePerPerson)} / orang',
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}
