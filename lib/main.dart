import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/api_service.dart';
import 'app/data/auth_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/shared/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('id_ID', null);

  // Register global services
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);

  runApp(const BajulanApp());
}

class BajulanApp extends StatelessWidget {
  const BajulanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kampung Adat Bajulan',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFBF7),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      initialRoute: Get.find<AuthService>().isLoggedIn.value
          ? AppRoutes.adminDashboard
          : AppRoutes.login,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
