import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/app/data/models/gallery_model.dart';

void main() {
  group('GalleryModel.fromJson', () {
    test('parse field standar', () {
      final json = {
        'id': 1,
        'title': 'Upacara Bersih Desa',
        'caption': 'Foto dokumentasi',
        'category': 'budaya',
        'is_featured': true,
        'full_url': 'https://kampungadatbajulan.pbltifnganjuk.com/storage/galleries/foto.jpg',
      };
      final m = GalleryModel.fromJson(json);
      expect(m.id, 1);
      expect(m.title, 'Upacara Bersih Desa');
      expect(m.caption, 'Foto dokumentasi');
      expect(m.isFeatured, true);
      expect(m.imageUrl, contains('foto.jpg'));
    });

    test('pakai full_url jika tersedia', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'full_url': 'https://example.com/img.jpg',
        'image_path': 'galleries/img.jpg',
      };
      final m = GalleryModel.fromJson(json);
      expect(m.imageUrl, 'https://example.com/img.jpg');
    });

    test('fallback ke image_url jika full_url null', () {
      final json = {
        'id': 2,
        'title': 'Test',
        'image_url': 'https://example.com/img2.jpg',
      };
      final m = GalleryModel.fromJson(json);
      expect(m.imageUrl, 'https://example.com/img2.jpg');
    });

    test('build URL dari image_path relatif', () {
      final json = {
        'id': 3,
        'title': 'Test',
        'image_path': 'galleries/foto.jpg',
      };
      final m = GalleryModel.fromJson(json);
      expect(m.imageUrl, contains('galleries/foto.jpg'));
      expect(m.imageUrl, startsWith('https://'));
    });

    test('is_featured false jika 0', () {
      final json = {'id': 4, 'title': 'Test', 'is_featured': 0};
      final m = GalleryModel.fromJson(json);
      expect(m.isFeatured, false);
    });

    test('fallback ke default jika field null', () {
      final json = <String, dynamic>{};
      final m = GalleryModel.fromJson(json);
      expect(m.title, '');
      expect(m.isFeatured, false);
      expect(m.imageUrl, '');
    });
  });

  group('GalleryModel.categoryLabel', () {
    test('kampung → Kampung Adat', () {
      expect(_gallery('kampung').categoryLabel, 'Kampung Adat');
    });
    test('budaya → Budaya', () {
      expect(_gallery('budaya').categoryLabel, 'Budaya');
    });
    test('alam → Alam', () {
      expect(_gallery('alam').categoryLabel, 'Alam');
    });
    test('kuliner → Kuliner', () {
      expect(_gallery('kuliner').categoryLabel, 'Kuliner');
    });
    test('event → Event', () {
      expect(_gallery('event').categoryLabel, 'Event');
    });
    test('lainnya → Lainnya', () {
      expect(_gallery('lainnya').categoryLabel, 'Lainnya');
    });
  });
}

GalleryModel _gallery(String category) => GalleryModel(
      id: 1,
      imageUrl: '',
      title: 'Test',
      category: category,
    );
