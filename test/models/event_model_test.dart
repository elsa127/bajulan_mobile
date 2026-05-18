import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/app/data/models/event_model.dart';

void main() {
  group('EventModel.fromJson', () {
    test('parse field standar', () {
      final json = {
        'id': 1,
        'name': 'Bersih Desa',
        'description': 'Festival tahunan',
        'event_date': '2026-07-01',
        'location': 'Punden Bajulan',
        'status': 'upcoming',
      };
      final m = EventModel.fromJson(json);
      expect(m.id, 1);
      expect(m.name, 'Bersih Desa');
      expect(m.eventDate, '2026-07-01');
      expect(m.location, 'Punden Bajulan');
      expect(m.status, 'upcoming');
    });

    test('fallback ke default jika field null', () {
      final json = <String, dynamic>{};
      final m = EventModel.fromJson(json);
      expect(m.name, '');
      expect(m.status, 'upcoming');
      expect(m.location, '');
    });

    test('parse nested package', () {
      final json = {
        'id': 2,
        'name': 'Event Budaya',
        'description': '',
        'event_date': '2026-08-01',
        'location': 'Bajulan',
        'status': 'ongoing',
        'package': {'id': 3, 'name': 'Paket Budaya'},
      };
      final m = EventModel.fromJson(json);
      expect(m.packageName, 'Paket Budaya');
    });
  });

  group('EventModel.imageUrl', () {
    test('return full_url jika ada', () {
      final m = EventModel(
        id: 1, name: '', description: '', eventDate: '',
        location: '', status: 'upcoming',
        fullUrl: 'https://example.com/img.jpg',
      );
      expect(m.imageUrl, 'https://example.com/img.jpg');
    });

    test('build URL dari imagePath', () {
      final m = EventModel(
        id: 1, name: '', description: '', eventDate: '',
        location: '', status: 'upcoming',
        imagePath: 'events/foto.jpg',
      );
      expect(m.imageUrl,
          'https://kampungadatbajulan.pbltifnganjuk.com/uploads/events/foto.jpg');
    });

    test('return null jika tidak ada gambar', () {
      final m = EventModel(
        id: 1, name: '', description: '', eventDate: '',
        location: '', status: 'upcoming',
      );
      expect(m.imageUrl, isNull);
    });
  });

  group('EventModel.statusLabel', () {
    test('upcoming → Upcoming', () {
      expect(_event('upcoming').statusLabel, 'Upcoming');
    });
    test('ongoing → Ongoing', () {
      expect(_event('ongoing').statusLabel, 'Ongoing');
    });
    test('done → Done', () {
      expect(_event('done').statusLabel, 'Done');
    });
    test('cancelled → Cancelled', () {
      expect(_event('cancelled').statusLabel, 'Cancelled');
    });
  });
}

EventModel _event(String status) => EventModel(
      id: 1,
      name: 'Test',
      description: '',
      eventDate: '2026-06-01',
      location: 'Test',
      status: status,
    );
