import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/notification_model.dart';
import '../../../app/data/models/booking_model.dart';
import '../../../app/routes/app_routes.dart';

class NotificationController extends GetxController {
  final _api = Get.find<ApiService>();
  final _box = GetStorage();

  static const _readKey = 'read_notification_ids';

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // ID notifikasi yang sudah dibaca, disimpan secara persisten
  final Set<String> _readIds = {};

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    // Muat ID yang sudah dibaca dari penyimpanan lokal
    final saved = _box.read<List>(_readKey);
    if (saved != null) {
      _readIds.addAll(saved.map((e) => e.toString()));
    }
    fetch();
  }

  // [BACA] Ambil notifikasi dari booking terbaru — GET /admin/bookings?limit=50
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.get('/admin/bookings?limit=50');
      final raw = res['data'] ?? res['bookings'] ?? [];
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];

      // Filter sisi klien: hanya 7 hari terakhir
      final cutoff = DateTime.now().subtract(const Duration(days: 7));

      final newNotifs = list
          .map((bookingJson) {
            final booking = BookingModel.fromJson(bookingJson);
            return _bookingToNotification(booking);
          })
          .where((n) => n.time.isAfter(cutoff))
          .toList();

      // Pertahankan status baca dari notifikasi yang sudah ada
      for (final notif in newNotifs) {
        final existing = notifications.firstWhereOrNull(
          (n) => n.uniqueId == notif.uniqueId,
        );
        if (existing != null && existing.isRead) {
          notif.isRead = true;
        }
      }

      notifications.value = newNotifs;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // Ubah data booking menjadi model notifikasi
  NotificationModel _bookingToNotification(BookingModel booking) {
    String title;
    String body;

    switch (booking.status.toLowerCase()) {
      case 'pending':
        title = 'Booking Baru';
        body =
            '${booking.guestName} memesan ${booking.package?.name ?? "paket"} untuk ${booking.totalPerson} orang';
        break;
      case 'paid':
        title = 'Pembayaran Diterima';
        body =
            '${booking.guestName} telah membayar ${booking.package?.name ?? "paket"}';
        break;
      case 'confirmed':
        title = 'Booking Dikonfirmasi';
        body = 'Booking ${booking.code} telah dikonfirmasi';
        break;
      case 'cancelled':
        title = 'Booking Dibatalkan';
        body = '${booking.guestName} membatalkan booking ${booking.code}';
        break;
      default:
        title = 'Update Booking';
        body = 'Booking ${booking.code} - ${booking.statusLabel}';
    }

    final uniqueId = booking.id?.toString() ?? booking.code;
    final alreadyRead = _readIds.contains(uniqueId);

    // Tandai sebagai baru hanya jika belum dibaca dan dibuat dalam 24 jam terakhir
    final isNew = !alreadyRead &&
        booking.createdAt != null &&
        DateTime.now()
                .difference(DateTime.parse(booking.createdAt!))
                .inHours <
            24;

    return NotificationModel(
      id: booking.id,
      type: NotifType.booking,
      title: title,
      body: body,
      time: booking.createdAt != null
          ? DateTime.parse(booking.createdAt!)
          : DateTime.now(),
      isRead: alreadyRead || !isNew,
      data: {
        'booking_id': booking.id,
        'booking_code': booking.code,
        'status': booking.status,
      },
    );
  }

  // [UBAH] Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.uniqueId == id);
    if (idx == -1) return;

    notifications[idx].isRead = true;
    notifications.refresh();

    _readIds.add(id);
    _saveReadIds();
  }

  // [UBAH] Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllRead() async {
    for (final n in notifications) {
      n.isRead = true;
      _readIds.add(n.uniqueId);
    }
    notifications.refresh();
    _saveReadIds();
  }

  void _saveReadIds() {
    _box.write(_readKey, _readIds.toList());
  }

  // Tangani tap notifikasi — navigasi ke detail booking
  void handleTap(NotificationModel notif) {
    markAsRead(notif.uniqueId);
    if (notif.bookingId != null) {
      Get.toNamed(
        AppRoutes.adminBookingDetail,
        arguments: {'id': notif.bookingId},
      );
    } else {
      Get.toNamed(AppRoutes.adminBookings);
    }
  }

  // Kelompokkan notifikasi berdasarkan label hari
  Map<String, List<NotificationModel>> get grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationModel>> result = {};
    for (final n in notifications) {
      final d = DateTime(n.time.year, n.time.month, n.time.day);
      String key;
      if (d == today) {
        key = 'HARI INI';
      } else if (d == yesterday) {
        key = 'KEMARIN';
      } else {
        key = '${d.day}/${d.month}/${d.year}';
      }
      result.putIfAbsent(key, () => []).add(n);
    }
    return result;
  }

  // Format waktu relatif (misal: "5 menit lalu")
  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }
}
