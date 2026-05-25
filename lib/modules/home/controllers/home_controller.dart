import 'package:get/get.dart';
import '../../../app/data/api_service.dart';
import '../../../app/data/models/package_model.dart';
import '../../../app/data/models/event_model.dart';
import '../../../app/data/models/gallery_model.dart';

class HomeController extends GetxController {
  final _api = Get.find<ApiService>();

  var isLoadingPackages = true.obs;
  var isLoadingEvents = true.obs;
  var packages = <PackageModel>[].obs;
  var events = <EventModel>[].obs;
  var galleries = <GalleryModel>[].obs;
  var errorPackages = ''.obs;
  var errorEvents = ''.obs;
  var selectedCategory = 'all'.obs;

  List<PackageModel> get filteredPackages {
    if (selectedCategory.value == 'all') return packages;
    return packages.where((p) => p.category == selectedCategory.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchPackages(), fetchEvents(), fetchGalleries()]);
  }

  Future<void> fetchPackages() async {
    isLoadingPackages.value = true;
    errorPackages.value = '';
    try {
      final res = await _api.get('/packages');
      final list = _extractList(res);
      packages.value = list.map((e) => PackageModel.fromJson(e)).toList();
    } catch (e) {
      errorPackages.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingPackages.value = false;
    }
  }

  Future<void> fetchEvents() async {
    isLoadingEvents.value = true;
    errorEvents.value = '';
    try {
      final res = await _api.get('/events');
      final list = _extractList(res);
      events.value = list.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      errorEvents.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> fetchGalleries() async {
    try {
      final res = await _api.get('/galleries');
      final list = _extractList(res);
      galleries.value = list.map((e) => GalleryModel.fromJson(e)).toList();
    } catch (_) {}
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> res) {
    final raw = res['data'] ?? res['packages'] ?? res['events'] ?? res['galleries'] ?? [];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
