import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/app/data/models/dashboard_model.dart';

void main() {
  group('DashboardModel.fromJson', () {
    test('parse response dengan wrapper data', () {
      final json = {
        'data': {
          'total_booking_hari_ini': 5,
          'total_pendapatan_bulan_ini': 2500000,
          'jumlah_paket_aktif': 3,
          'booking_terbaru': [],
        }
      };
      final m = DashboardModel.fromJson(json);
      expect(m.totalBookingHariIni, 5);
      expect(m.totalPendapatanBulanIni, 2500000);
      expect(m.jumlahPaketAktif, 3);
    });

    test('parse response tanpa wrapper data', () {
      final json = {
        'total_booking_hari_ini': 2,
        'total_pendapatan_bulan_ini': 100000,
        'jumlah_paket_aktif': 1,
        'booking_terbaru': [],
      };
      final m = DashboardModel.fromJson(json);
      expect(m.totalBookingHariIni, 2);
      expect(m.totalPendapatanBulanIni, 100000);
    });

    test('parse decimal string dari Laravel', () {
      final json = {
        'data': {
          'total_booking_hari_ini': '3',
          'total_pendapatan_bulan_ini': '750000.00',
          'jumlah_paket_aktif': '5',
          'booking_terbaru': [],
        }
      };
      final m = DashboardModel.fromJson(json);
      expect(m.totalPendapatanBulanIni, 750000);
      expect(m.jumlahPaketAktif, 5);
    });

    test('fallback ke 0 jika field null', () {
      final json = <String, dynamic>{};
      final m = DashboardModel.fromJson(json);
      expect(m.totalBookingHariIni, 0);
      expect(m.totalPendapatanBulanIni, 0);
      expect(m.jumlahPaketAktif, 0);
      expect(m.bookingTerbaru, isEmpty);
    });

    test('parse booking_terbaru list', () {
      final json = {
        'data': {
          'total_booking_hari_ini': 1,
          'total_pendapatan_bulan_ini': 50000,
          'jumlah_paket_aktif': 1,
          'booking_terbaru': [
            {'id': 1, 'guest_name': 'Budi', 'status': 'paid'},
            {'id': 2, 'guest_name': 'Ani', 'status': 'pending'},
          ],
        }
      };
      final m = DashboardModel.fromJson(json);
      expect(m.bookingTerbaru.length, 2);
      expect(m.bookingTerbaru[0]['guest_name'], 'Budi');
    });
  });
}
