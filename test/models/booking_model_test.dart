import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/app/data/models/booking_model.dart';

void main() {
  group('BookingModel.fromJson', () {
    test('parse field standar dengan benar', () {
      final json = {
        'id': 1,
        'booking_code': 'KAB-001',
        'guest_name': 'Budi',
        'guest_phone': '08123456789',
        'visit_date': '2026-06-01',
        'total_person': 3,
        'status': 'pending',
        'total_price': 150000,
      };
      final m = BookingModel.fromJson(json);
      expect(m.id, 1);
      expect(m.code, 'KAB-001');
      expect(m.guestName, 'Budi');
      expect(m.totalPerson, 3);
      expect(m.totalPrice, 150000);
      expect(m.status, 'pending');
    });

    test('parse total_price decimal string dari Laravel', () {
      final json = {
        'booking_code': 'KAB-002',
        'guest_name': 'Ani',
        'guest_phone': '08111',
        'visit_date': '2026-06-01',
        'total_person': 2,
        'status': 'paid',
        'total_price': '50000.00', // decimal string dari DB
      };
      final m = BookingModel.fromJson(json);
      expect(m.totalPrice, 50000);
    });

    test('parse total_price sebagai double', () {
      final json = {
        'booking_code': 'KAB-003',
        'guest_name': 'Cici',
        'guest_phone': '08222',
        'visit_date': '2026-06-01',
        'total_person': 1,
        'status': 'paid',
        'total_price': 75000.00,
      };
      final m = BookingModel.fromJson(json);
      expect(m.totalPrice, 75000);
    });

    test('fallback ke default jika field null', () {
      final json = <String, dynamic>{};
      final m = BookingModel.fromJson(json);
      expect(m.code, '-');
      expect(m.guestName, '-');
      expect(m.totalPrice, 0);
      expect(m.status, 'pending');
      expect(m.totalPerson, 0);
    });

    test('parse nested package', () {
      final json = {
        'booking_code': 'KAB-004',
        'guest_name': 'Dodi',
        'guest_phone': '08333',
        'visit_date': '2026-06-01',
        'total_person': 2,
        'status': 'paid',
        'total_price': 100000,
        'package': {'id': 5, 'name': 'Trabas Wilis'},
      };
      final m = BookingModel.fromJson(json);
      expect(m.package, isNotNull);
      expect(m.package!.id, 5);
      expect(m.package!.name, 'Trabas Wilis');
    });

    test('parse nested payment', () {
      final json = {
        'booking_code': 'KAB-005',
        'guest_name': 'Eko',
        'guest_phone': '08444',
        'visit_date': '2026-06-01',
        'total_person': 1,
        'status': 'paid',
        'total_price': 50000,
        'payment': {
          'id': 10,
          'payment_method': 'gopay',
          'status': 'settlement',
          'amount': '50000.00',
        },
      };
      final m = BookingModel.fromJson(json);
      expect(m.payment, isNotNull);
      expect(m.payment!.method, 'gopay');
      expect(m.payment!.amount, 50000);
    });
  });

  group('BookingModel.statusLabel', () {
    test('paid → Lunas', () {
      final m = _booking(status: 'paid');
      expect(m.statusLabel, 'Lunas');
    });
    test('confirmed → Dikonfirmasi', () {
      final m = _booking(status: 'confirmed');
      expect(m.statusLabel, 'Dikonfirmasi');
    });
    test('pending → Menunggu', () {
      final m = _booking(status: 'pending');
      expect(m.statusLabel, 'Menunggu');
    });
    test('cancelled → Dibatalkan', () {
      final m = _booking(status: 'cancelled');
      expect(m.statusLabel, 'Dibatalkan');
    });
    test('expired → Kedaluwarsa', () {
      final m = _booking(status: 'expired');
      expect(m.statusLabel, 'Kedaluwarsa');
    });
    test('unknown status → uppercase', () {
      final m = _booking(status: 'refunded');
      expect(m.statusLabel, 'REFUNDED');
    });
  });
}

BookingModel _booking({String status = 'pending'}) => BookingModel(
      code: 'KAB-TEST',
      guestName: 'Test',
      guestPhone: '08000',
      visitDate: '2026-06-01',
      totalPerson: 1,
      status: status,
      totalPrice: 50000,
    );
