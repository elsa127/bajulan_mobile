import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../data/auth_service.dart';

// Public
import '../../modules/login/home/views/home_view.dart';
import '../../modules/login/home/controllers/home_controller.dart';
import '../../modules/packages/views/package_detail_view.dart';
import '../../modules/packages/controllers/package_detail_controller.dart';
import '../../modules/booking/views/booking_form_view.dart';
import '../../modules/booking/controllers/booking_form_controller.dart';
import '../../modules/booking/views/payment_view.dart';
import '../../modules/booking/views/booking_status_view.dart';
import '../../modules/booking/controllers/booking_status_controller.dart';

// Auth
import '../../modules/login/views/login.dart';
import '../../modules/login/controllers/login_controller.dart';

// Admin
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../modules/packages/views/admin_packages_view.dart';
import '../../modules/packages/controllers/admin_packages_controller.dart';
import '../../modules/packages/views/add_package_view.dart';
import '../../modules/packages/controllers/package_controller.dart';
import '../../modules/events/views/event_view.dart';
import '../../modules/events/controllers/event_controller.dart';
import '../../modules/bookings/views/booking_view.dart';
import '../../modules/bookings/controllers/booking_controller.dart';
import '../../modules/bookings/views/booking_detail_view.dart';
import '../../modules/bookings/controllers/booking_detail_controller.dart';
import '../../modules/login/galleries/views/gallery_view.dart';
import '../../modules/login/galleries/controllers/gallery_controller.dart';
import '../../modules/notifications/views/notification_view.dart';
import '../../modules/notifications/controllers/notification_controller.dart';

class AppPages {
  static final pages = [
    // ── PUBLIC ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController(), fenix: true)),
    ),
    GetPage(
      name: AppRoutes.packageDetail,
      page: () => const PackageDetailView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PackageDetailController(), fenix: true)),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingFormView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BookingFormController(), fenix: true)),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentView(),
    ),
    GetPage(
      name: AppRoutes.bookingStatus,
      page: () => const BookingStatusView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BookingStatusController(), fenix: true)),
    ),

    // ── AUTH ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController(), fenix: true)),
    ),

    // ── ADMIN ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DashboardController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminPackages,
      page: () => const AdminPackagesView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AdminPackagesController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminAddPackage,
      page: () => const AddPackageView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PackageController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminEvents,
      page: () => const EventView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => EventController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminBookings,
      page: () => const BookingView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BookingController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminBookingDetail,
      page: () => const BookingDetailView(),
      binding: BindingsBuilder(
          () => Get.lazyPut(() => BookingDetailController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminGalleries,
      page: () => const GalleryView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => GalleryController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminNotifications,
      page: () => const NotificationView(),
      binding: BindingsBuilder(
          () => Get.lazyPut(() => NotificationController(), fenix: true)),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

// ── Auth Guard ──────────────────────────────────────────
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (!auth.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
