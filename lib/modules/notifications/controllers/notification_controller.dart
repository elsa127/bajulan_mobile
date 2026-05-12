import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/notification_model.dart';
import '../../../app/data/models/booking_model.dart';
import '../../../app/routes/app_routes.dart';

class NotificationController extends GetxController {
  final _api = Get.find<ApiService>();

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  // ── Fetch dari booking recent ─────────────────────────
  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      // Ambil booking terbaru (24 jam terakhir)
      final res = await _api.get('/admin/bookings?recent=true&limit=20');
      final raw = res['data'] ?? res['bookings'] ?? [];
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];

      // Convert booking ke notification
      notifications.value = list.map((bookingJson) {
        final booking = BookingModel.fromJson(bookingJson);
        return _bookingToNotification(booking);
      }).toList();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      // Fallback ke dummy jika error
      _loadDummy();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Convert booking ke notification ───────────────────
  NotificationModel _bookingToNotification(BookingModel booking) {
    String title;
    String body;
    NotifType type = NotifType.booking;

    // Generate title & body berdasarkan status
    switch (booking.status.toLowerCase()) {
      case 'pending':
        title = 'Booking Baru';
        body = '${booking.guestName} memesan ${booking.package?.name ?? "paket"} untuk ${booking.totalPerson} orang';
        break;
      case 'paid':
        title = 'Pembayaran Diterima';
        body = '${booking.guestName} telah membayar ${booking.package?.name ?? "paket"}';
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

    // Booking baru (< 24 jam) = unread
    final isNew = booking.createdAt != null &&
        DateTime.now().difference(DateTime.parse(booking.createdAt!)).inHours < 24;

    return NotificationModel(
      id: booking.id,
      type: type,
      title: title,
      body: body,
      time: booking.createdAt != null
          ? DateTime.parse(booking.createdAt!)
          : DateTime.now(),
      isRead: !isNew, // Booking baru = unread
      data: {
        'booking_id': booking.id,
        'booking_code': booking.code,
        'status': booking.status,
      },
    );
  }

  // ── Mark as read (local only) ─────────────────────────
  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.uniqueId == id);
    if (idx == -1) return;

    notifications[idx].isRead = true;
    notifications.refresh();
  }

  // ── Mark all as read (local only) ─────────────────────
  Future<void> markAllRead() async {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  // ── Handle notification tap ───────────────────────────
  void handleTap(NotificationModel notif) {
    markAsRead(notif.uniqueId);

    // Navigate ke booking detail
    if (notif.bookingId != null) {
      Get.toNamed(
        AppRoutes.adminBookingDetail,
        arguments: {'id': notif.bookingId},
      );
    } else {
      Get.toNamed(AppRoutes.adminBookings);
    }
  }

  // ── Dummy data untuk fallback ─────────────────────────
  void _loadDummy() {
    final now = DateTime.now();
    notifications.value = [
      NotificationModel(
        notifId: '1',
        type: NotifType.booking,
        title: 'Booking Baru',
        body: "Aditya Pratama memesan 'Paket Budaya' untuk 5 orang",
        time: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'booking_id': 1},
      ),
      NotificationModel(
        notifId: '2',
        type: NotifType.booking,
        title: 'Pembayaran Diterima',
        body: 'Budi Santoso telah membayar Paket Alam',
        time: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        data: {'booking_id': 2},
      ),
      NotificationModel(
        notifId: '3',
        type: NotifType.booking,
        title: 'Booking Dikonfirmasi',
        body: 'Booking BK-003 telah dikonfirmasi',
        time: now.subtract(const Duration(hours: 26)),
        isRead: true,
        data: {'booking_id': 3},
      ),
    ];
  }

  // ── Kelompokkan berdasarkan hari ──────────────────────
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

  // ── Time ago helper ────────────────────────────────────
  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }
}
