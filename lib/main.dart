import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/api_service.dart';
import 'app/data/auth_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/shared/colors.dart';
import 'app/services/notification_service.dart';
import 'modules/notifications/controllers/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Jalankan init yang bisa diparalelkan
  await Future.wait([
    GetStorage.init(),
    initializeDateFormatting('id_ID', null),
    Firebase.initializeApp(),
    // Pre-cache font agar tidak download saat render pertama
    GoogleFonts.pendingFonts([
      GoogleFonts.plusJakartaSans(),
    ]),
  ]);

  // Register services
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(NotificationController(), permanent: true);

  // Sembunyikan status bar untuk splash yang lebih clean
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Jalankan app
  runApp(const BajulanApp());

  // Init notification service di background
  Get.putAsync(() => NotificationService().init(), permanent: true);
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
          backgroundColor: AppColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
