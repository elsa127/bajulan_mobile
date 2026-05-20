import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _box = GetStorage();

  late final TextEditingController usernameCtrl;
  late final TextEditingController passwordCtrl;

  var isObscured = true.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;
  var usernameError = false.obs;
  var passwordError = false.obs;

  @override
  void onInit() {
    super.onInit();
    usernameCtrl = TextEditingController();
    passwordCtrl = TextEditingController();

    // Hilangkan border merah saat user mulai mengetik
    usernameCtrl.addListener(() => usernameError.value = false);
    passwordCtrl.addListener(() => passwordError.value = false);

    // Isi username tersimpan jika remember me aktif
    final saved = _box.read<String>('saved_username');
    if (saved != null) {
      usernameCtrl.text = saved;
      rememberMe.value = true;
    }
  }

  void toggleObscure() => isObscured.value = !isObscured.value;
  void toggleRemember() => rememberMe.value = !rememberMe.value;

  // [LOGIN] POST /auth/login
  Future<void> login() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      usernameError.value = username.isEmpty;
      passwordError.value = password.isEmpty;
      Get.snackbar('Peringatan', 'Username dan kata sandi harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    usernameError.value = false;
    passwordError.value = false;
    try {
      await _auth.login(username, password);

      if (rememberMe.value) {
        _box.write('saved_username', username);
      } else {
        _box.remove('saved_username');
      }

      Get.offAllNamed(AppRoutes.adminDashboard);
    } catch (e) {
      // API tidak membedakan field mana yang salah — merahkan keduanya
      usernameError.value = true;
      passwordError.value = true;
      Get.snackbar('Login Gagal', e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Tidak dispose controller — fenix: true bisa recreate controller ini
    super.onClose();
  }
}
