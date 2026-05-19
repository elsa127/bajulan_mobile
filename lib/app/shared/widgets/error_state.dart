import 'package:flutter/material.dart';
import '../colors.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isNoInternet = message.contains('koneksi internet') ||
        message.contains('WiFi') ||
        message.contains('data seluler') ||
        message.contains('terhubung ke server');
    final isTimeout = message.contains('lambat') ||
        message.contains('merespons') ||
        message.contains('Timeout');
    final isServer = message.contains('server') &&
        (message.contains('kesalahan') || message.contains('bermasalah'));

    IconData icon;
    Color iconColor;
    String title;

    if (isNoInternet) {
      icon = Icons.wifi_off_rounded;
      iconColor = AppColors.outline;
      title = 'Tidak Ada Koneksi';
    } else if (isTimeout) {
      icon = Icons.timer_off_outlined;
      iconColor = AppColors.secondary;
      title = 'Koneksi Lambat';
    } else if (isServer) {
      icon = Icons.cloud_off_outlined;
      iconColor = AppColors.error;
      title = 'Server Bermasalah';
    } else {
      icon = Icons.error_outline_rounded;
      iconColor = AppColors.outline;
      title = 'Terjadi Kesalahan';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.outline,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
