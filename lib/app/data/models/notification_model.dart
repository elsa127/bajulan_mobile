enum NotifType { booking, message, event, system }

class NotificationModel {
  final int? id;
  final String? notifId; // untuk backward compatibility
  final NotifType type;
  final String title;
  final String body;
  final String? preview;
  final DateTime time;
  bool isRead;
  final Map<String, dynamic>? data; // Extra data (booking_id, etc)

  NotificationModel({
    this.id,
    this.notifId,
    required this.type,
    required this.title,
    required this.body,
    this.preview,
    required this.time,
    this.isRead = false,
    this.data,
  });

  // Getter untuk ID yang fleksibel
  String get uniqueId => id?.toString() ?? notifId ?? '';

  // Getter untuk booking ID jika ada
  int? get bookingId => data?['booking_id'] as int?;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseInt(json['id']),
      notifId: json['notif_id'] as String?,
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      preview: json['preview'] as String?,
      time: _parseTime(json['created_at'] ?? json['time']),
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['read_at'] != null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  static NotifType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return NotifType.booking;
      case 'message':
        return NotifType.message;
      case 'event':
        return NotifType.event;
      case 'system':
        return NotifType.system;
      default:
        return NotifType.system;
    }
  }

  static DateTime _parseTime(dynamic time) {
    if (time == null) return DateTime.now();
    if (time is DateTime) return time;
    if (time is String) {
      try {
        return DateTime.parse(time);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
