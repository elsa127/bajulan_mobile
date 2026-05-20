import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../data/api_service.dart';
import '../routes/app_routes.dart';
import '../../modules/notifications/controllers/notification_controller.dart';

// Handler background/terminated — harus di luar class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'bajulan_booking';
  static const _channelName = 'Booking Notifications';
  static const _channelDesc = 'Notifikasi booking baru dan update status';

  String? fcmToken;

  Future<NotificationService> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setupFCM();
    return this;
  }

  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotifTap,
    );

    // Android 8+ wajib mendaftarkan channel notifikasi secara eksplisit
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            showBadge: true,
          ),
        );
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    try {
      fcmToken = await _fcm.getToken();
      // ignore: avoid_print
      print('🔑 FCM Token: $fcmToken');
      if (fcmToken == null) {
        // ignore: avoid_print
        print('❌ FCM Token NULL - cek google-services.json dan SHA-1');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ FCM getToken error: $e');
    }

    // Semua admin menerima notifikasi booking lewat topic ini
    await _fcm.subscribeToTopic('admin_booking');
    // ignore: avoid_print
    print('✅ Subscribed to topic: admin_booking');

    // Notifikasi saat app terbuka (foreground)
    FirebaseMessaging.onMessage.listen((message) {
      // ignore: avoid_print
      print('📨 Foreground message: ${message.notification?.title}');
      _showLocalNotif(message);
      _refreshNotifList();
    });

    // Notifikasi saat app di background (tidak terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromMessage);

    // Notifikasi saat app baru dibuka dari terminated
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _navigateFromMessage(initial);
  }

  // Tampilkan notifikasi lokal di perangkat
  Future<void> _showLocalNotif(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    await _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          enableLights: true,
          fullScreenIntent: false,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['booking_id']?.toString(),
    );
  }

  // Navigasi ke halaman detail booking dari notifikasi
  void _navigateFromMessage(RemoteMessage message) {
    final bookingId = message.data['booking_id'];
    if (bookingId != null) {
      Get.toNamed(
        AppRoutes.adminBookingDetail,
        arguments: {'id': int.tryParse(bookingId.toString())},
      );
    } else {
      Get.toNamed(AppRoutes.adminBookings);
    }
  }

  // Navigasi saat notifikasi lokal di-tap
  void _onLocalNotifTap(NotificationResponse response) {
    if (response.payload != null) {
      final bookingId = int.tryParse(response.payload!);
      if (bookingId != null) {
        Get.toNamed(
          AppRoutes.adminBookingDetail,
          arguments: {'id': bookingId},
        );
      }
    }
  }

  // Perbarui daftar notifikasi di halaman notifikasi
  void _refreshNotifList() {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetch();
    }
  }
}
