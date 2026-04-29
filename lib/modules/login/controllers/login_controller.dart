import 'package:get/get.dart';

class LoginController extends GetxController {
  var isObscured = true.obs;

  // TAMBAHKAN DUA BARIS INI:
  var rememberMe = false.obs;

  void toggleObscure() {
    isObscured.value = !isObscured.value;
  }

  // TAMBAHKAN FUNGSI INI:
  void toggleRemember(bool? value) {
    rememberMe.value = value ?? false;
  }

  void login() {
    print("Mencoba Login...");
  }
}