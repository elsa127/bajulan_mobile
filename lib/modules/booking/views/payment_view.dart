import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../app/shared/colors.dart';
import '../../../app/core/constants.dart';
import '../../../app/routes/app_routes.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  late final String _bookingCode;
  late final String _snapToken;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _bookingCode = args['booking_code'] as String? ?? '';
    _snapToken = args['snap_token'] as String? ?? '';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (req) {
          // Midtrans redirect setelah pembayaran
          final url = req.url;
          if (url.contains('finish') ||
              url.contains('success') ||
              url.contains('unfinish') ||
              url.contains('error')) {
            Get.offNamed(AppRoutes.bookingStatus,
                arguments: {'booking_code': _bookingCode});
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(
          Uri.parse('${AppConstants.midtransSnapUrl}/$_snapToken'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showCancelDialog(),
        ),
        title: const Text('Pembayaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_bookingCode.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(_bookingCode,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
            'Booking Anda sudah dibuat. Anda bisa melanjutkan pembayaran nanti dengan kode booking.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Lanjutkan Bayar',
                style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offNamed(AppRoutes.bookingStatus,
                  arguments: {'booking_code': _bookingCode});
            },
            child: const Text('Cek Status', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}
