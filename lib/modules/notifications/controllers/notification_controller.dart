import 'package:get/get.dart';
import '../../../app/data/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadDummy();
  }

  void _loadDummy() {
    final now = DateTime.now();
    notifications.value = [
      // TODAY
      NotificationModel(
        id: '1',
        type: NotifType.booking,
        title: 'New Booking',
        body: "Aditya Pratama booked 'Cultural Heritage Tour' for Oct 24.",
        time: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        type: NotifType.message,
        title: 'New Message',
        body: 'Budi Santoso sent a message regarding his booking.',
        preview: '"Halo admin, apakah saya bisa menambah 5 orang lagi untuk..."',
        time: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      // YESTERDAY
      NotificationModel(
        id: '3',
        type: NotifType.event,
        title: 'Event Update',
        body: "Reminder: 'Bersih Desa Slametan' starts in 2 hours.",
        time: now.subtract(const Duration(hours: 26)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        type: NotifType.system,
        title: 'System Alert',
        body: 'Payout for Transaction #BK-99283 is being processed.',
        time: now.subtract(const Duration(hours: 29)),
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
    }
  }

  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  // Kelompokkan berdasarkan hari
  Map<String, List<NotificationModel>> get grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationModel>> result = {};
    for (final n in notifications) {
      final d = DateTime(n.time.year, n.time.month, n.time.day);
      String key;
      if (d == today) {
        key = 'TODAY';
      } else if (d == yesterday) {
        key = 'YESTERDAY';
      } else {
        key = '${d.day}/${d.month}/${d.year}';
      }
      result.putIfAbsent(key, () => []).add(n);
    }
    return result;
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
