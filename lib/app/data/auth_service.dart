import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants.dart';
import '../services/notification_service.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  final _api = Get.find<ApiService>();
  final _box = GetStorage();

  final isLoggedIn = false.obs;
  final user = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    final token = _box.read<String>(AppConstants.tokenKey);
    if (token != null) {
      isLoggedIn.value = true;
      final saved = _box.read<Map>(AppConstants.userKey);
      if (saved != null) {
        user.value = Map<String, dynamic>.from(saved);
      }
      _fetchMe();
    }
  }

  Future<void> login(String email, String password) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    // Response struktur: { success: true, data: { user: {...}, token: "..." } }
    final data = res['data'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;

    if (token == null) {
      final msg = res['message'] as String? ?? 'Login gagal.';
      throw Exception(msg);
    }

    _box.write(AppConstants.tokenKey, token);

    final userData = data?['user'] as Map<String, dynamic>?;
    if (userData != null) {
      _box.write(AppConstants.userKey, userData);
      user.value = userData;
    }
    isLoggedIn.value = true;

    // Simpan FCM token ke backend setelah login
    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().saveTokenToBackend();
    }
  }

  Future<void> _fetchMe() async {
    try {
      final res = await _api.get('/auth/me');
      // Response: { success: true, data: { id, name, email, ... } }
      final userData = res['data'] as Map<String, dynamic>?;
      if (userData != null) {
        user.value = userData;
        _box.write(AppConstants.userKey, userData);
      }
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } catch (_) {
      // tetap lanjut logout
    } finally {
      _box.remove(AppConstants.tokenKey);
      _box.remove(AppConstants.userKey);
      isLoggedIn.value = false;
      user.value = null;
      Get.offAllNamed('/login');
    }
  }

  String get userName => user.value?['name'] as String? ?? 'Admin';
  String get userEmail => user.value?['email'] as String? ?? '';
  String get userRole => user.value?['role'] as String? ?? '';
}
