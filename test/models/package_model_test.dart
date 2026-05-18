import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/app/data/models/package_model.dart';

void main() {
  group('PackageModel.fromJson', () {
    test('parse field standar', () {
      final json = {
        'id': 1,
        'name': 'Trabas Wilis',
        'description': 'Petualangan seru',
        'terms': 'Bawa helm',
        'price_per_person': 50000,
        'min_person': 2,
        'category': 'trabas',
        'status': 'active',
      };
      final m = PackageModel.fromJson(json);
      expect(m.id, 1);
      expect(m.name, 'Trabas Wilis');
      expect(m.pricePerPerson, 50000);
      expect(m.minPerson, 2);
      expect(m.isPublished, true);
    });

    test('parse price_per_person decimal string', () {
      final json = {
        'id': 2,
        'name': 'Paket Budaya',
        'description': '',
        'terms': '',
        'price_per_person': '75000.00',
        'min_person': '5',
        'category': 'kampung_adat',
        'status': 'active',
      };
      final m = PackageModel.fromJson(json);
      expect(m.pricePerPerson, 75000);
      expect(m.minPerson, 5);
    });

    test('fallback ke default jika field null', () {
      final json = <String, dynamic>{};
      final m = PackageModel.fromJson(json);
      expect(m.name, '');
      expect(m.pricePerPerson, 0);
      expect(m.minPerson, 1);
      expect(m.category, 'kampung_adat');
      expect(m.status, 'active');
    });

    test('parse images list', () {
      final json = {
        'id': 3,
        'name': 'Paket Alam',
        'description': '',
        'terms': '',
        'price_per_person': 60000,
        'min_person': 3,
        'category': 'pendakian',
        'status': 'active',
        'images': [
          {'id': 1, 'image_path': 'img1.jpg', 'is_cover': true, 'sort_order': 0},
          {'id': 2, 'image_path': 'img2.jpg', 'is_cover': false, 'sort_order': 1},
        ],
      };
      final m = PackageModel.fromJson(json);
      expect(m.images.length, 2);
      expect(m.images[0].isCover, true);
    });
  });

  group('PackageModel.categoryLabel', () {
    test('kampung_adat → Budaya', () {
      expect(_pkg('kampung_adat').categoryLabel, 'Budaya');
    });
    test('pendakian → Alam', () {
      expect(_pkg('pendakian').categoryLabel, 'Alam');
    });
    test('budaya_seni → Ritual', () {
      expect(_pkg('budaya_seni').categoryLabel, 'Ritual');
    });
    test('edukasi_durian → Kuliner', () {
      expect(_pkg('edukasi_durian').categoryLabel, 'Kuliner');
    });
    test('trabas → Petualangan', () {
      expect(_pkg('trabas').categoryLabel, 'Petualangan');
    });
    test('unknown → return as-is', () {
      expect(_pkg('unknown').categoryLabel, 'unknown');
    });
  });

  group('PackageModel getters', () {
    test('isPublished true jika status active', () {
      expect(_pkg('kampung_adat', status: 'active').isPublished, true);
    });
    test('isPublished false jika status inactive', () {
      expect(_pkg('kampung_adat', status: 'inactive').isPublished, false);
    });
  });
}

PackageModel _pkg(String category, {String status = 'active'}) => PackageModel(
      id: 1,
      name: 'Test',
      description: '',
      terms: '',
      pricePerPerson: 50000,
      minPerson: 1,
      category: category,
      status: status,
    );
