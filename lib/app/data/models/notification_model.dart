enum NotifType { booking, message, event, system }

class NotificationModel {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String? preview; // untuk pesan
  final DateTime time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.preview,
    required this.time,
    this.isRead = false,
  });
}
