abstract class AppRoutes {
  // Public
  static const home = '/';
  static const packageDetail = '/package/:id';
  static const booking = '/booking/:id';
  static const payment = '/payment';
  static const bookingStatus = '/booking-status';

  // Auth
  static const login = '/login';

  // Admin
  static const adminDashboard = '/admin/dashboard';
  static const adminPackages = '/admin/packages';
  static const adminAddPackage = '/admin/packages/add';
  static const adminEvents = '/admin/events';
  static const adminBookings = '/admin/bookings';
  static const adminGalleries = '/admin/galleries';
}
