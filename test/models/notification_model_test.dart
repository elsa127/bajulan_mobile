import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/app/data/models/notification_model.dart';

void main() {
  group('NotificationModel.fromJson', () {
    test('parse field standar', () {
      final json = {
        'id': 1,
        'type': 'booking',
        'title': 'Booking Baru',
        'body': 'Budi memesan paket',
        'is_read': false,
        'created_at': '2026-05-13T10:00:00.000Z',
      };
      final m = NotificationModel.fromJson(json);
      expect(m.id, 1);
      expect(m.type, NotifType.booking);
      expect(m.title, 'Booking Baru');
      expect(m.isRead, false);
    });

    test('parse is_read dari integer 1', () {
      final json = {
        'id': 2,
        'type': 'system',
        'title': 'Test',
        'body': 'Test',
        'is_read': 1,
        'created_at': '2026-05-13T10:00:00.000Z',
      };
      final m = NotificationModel.fromJson(json);
      expect(m.isRead, true);
    });

    test('parse is_read dari read_at tidak null', () {
      final json = {
        'id': 3,
        'type': 'booking',
        'title': 'Test',
        'body': 'Test',
        'is_read': false,
        'read_at': '2026-05-13T11:00:00.000Z',
        'created_at': '2026-05-13T10:00:00.000Z',
      };
      final m = NotificationModel.fromJson(json);
      expect(m.isRead, true);
    });

    test('parse semua tipe notifikasi', () {
      for (final entry in {
        'booking': NotifType.booking,
        'message': NotifType.message,
        'event': NotifType.event,
        'system': NotifType.system,
        'unknown': NotifType.system,
      }.entries) {
        final json = {
          'type': entry.key,
          'title': '',
          'body': '',
          'created_at': '2026-05-13T10:00:00.000Z',
        };
        expect(NotificationModel.fromJson(json).type, entry.value,
            reason: 'type "${entry.key}" harus jadi ${entry.value}');
      }
    });
  });

  group('NotificationModel.uniqueId', () {
    test('pakai id jika ada', () {
      final m = NotificationModel(
        id: 5,
        type: NotifType.booking,
        title: '',
        body: '',
        time: DateTime.now(),
      );
      expect(m.uniqueId, '5');
    });

    test('pakai notifId jika id null', () {
      final m = NotificationModel(
        notifId: 'abc-123',
        type: NotifType.booking,
        title: '',
        body: '',
        time: DateTime.now(),
      );
      expect(m.uniqueId, 'abc-123');
    });

    test('return empty string jika keduanya null', () {
      final m = NotificationModel(
        type: NotifType.booking,
        title: '',
        body: '',
        time: DateTime.now(),
      );
      expect(m.uniqueId, '');
    });
  });

  group('NotificationModel.bookingId', () {
    test('return booking_id dari data', () {
      final m = NotificationModel(
        type: NotifType.booking,
        title: '',
        body: '',
        time: DateTime.now(),
        data: {'booking_id': 42},
      );
      expect(m.bookingId, 42);
    });

    test('return null jika data null', () {
      final m = NotificationModel(
        type: NotifType.booking,
        title: '',
        body: '',
        time: DateTime.now(),
      );
      expect(m.bookingId, isNull);
    });
  });
}
