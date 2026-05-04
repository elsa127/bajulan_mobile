import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/shared/colors.dart';
import '../../../app/data/models/notification_model.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: c.markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_outlined,
                    size: 56, color: AppColors.muted),
                SizedBox(height: 12),
                Text('Tidak ada notifikasi.',
                    style: TextStyle(color: AppColors.outline)),
              ],
            ),
          );
        }

        final grouped = c.grouped;
        final sections = grouped.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          itemCount: sections.length,
          itemBuilder: (_, si) {
            final section = sections[si];
            final items = grouped[section]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    section,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                ...items.map((n) => _NotifCard(notif: n, c: c)),
              ],
            );
          },
        );
      }),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final NotificationController c;
  const _NotifCard({required this.notif, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => c.markAsRead(notif.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            _buildIcon(),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            c.timeAgo(notif.time),
                            style: const TextStyle(
                                color: AppColors.outline, fontSize: 11),
                          ),
                          if (!notif.isRead) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                        color: AppColors.onSurface, fontSize: 13, height: 1.4),
                  ),
                  // Preview bubble (untuk pesan)
                  if (notif.preview != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2ED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notif.preview!,
                        style: const TextStyle(
                            color: AppColors.outline,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color bg;
    Color iconColor;
    IconData icon;

    switch (notif.type) {
      case NotifType.booking:
        bg = AppColors.primary.withValues(alpha: 0.12);
        iconColor = AppColors.primary;
        icon = Icons.calendar_today_outlined;
        break;
      case NotifType.message:
        bg = AppColors.primary.withValues(alpha: 0.12);
        iconColor = AppColors.primary;
        icon = Icons.chat_bubble_outline;
        break;
      case NotifType.event:
        bg = AppColors.tertiary.withValues(alpha: 0.15);
        iconColor = AppColors.tertiary;
        icon = Icons.event_outlined;
        break;
      case NotifType.system:
        bg = AppColors.secondary.withValues(alpha: 0.15);
        iconColor = AppColors.secondary;
        icon = Icons.account_balance_wallet_outlined;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}
