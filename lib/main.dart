import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules/login/views/login.dart';
import 'modules/dashboard/views/dashboard_view.dart';
import 'modules/packages/views/add_package_view.dart';
import 'package:bajulan_mobile/modules/events/views/event_view.dart';

void main() {
  runApp(const BajulanApp());
}

class BajulanApp extends StatelessWidget {
  const BajulanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bajulan Admin',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // Atur rute awal dan daftar halaman
      initialRoute: '/dashboard',
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/dashboard', page: () => const DashboardView()),
        GetPage(name: '/add-package', page: () => const AddPackageView()),
        GetPage(name: '/events', page: () => const EventView()),
      ],
    );
  }
}