import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  final _api = Get.find<ApiService>();
  final _box = GetStorage();

  final isLoggedIn = false.obs;
  final user = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    // Cek token tersimpan saat app dibuka
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

  // [LOGIN] POST /auth/login
  Future<void> login(String email, String password) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    // Respons: { success: true, data: { user: {...}, token: "..." } }
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
  }

  // Refresh data user saat startup — GET /auth/me
  Future<void> _fetchMe() async {
    try {
      final res = await _api.get('/auth/me');
      final userData = res['data'] as Map<String, dynamic>?;
      if (userData != null) {
        user.value = userData;
        _box.write(AppConstants.userKey, userData);
      }
    } catch (_) {
      await logout();
    }
  }

  // [LOGOUT] POST /auth/logout
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } catch (_) {
      // Tetap lanjut logout meski request gagal
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
