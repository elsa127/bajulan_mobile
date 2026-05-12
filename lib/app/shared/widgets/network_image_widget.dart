import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: Disabled to reduce log noise
    // if (url != null && url!.isNotEmpty) {
    //   debugPrint('[AppNetworkImage] Loading: $url');
    // }
    
    final widget = url != null && url!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => _placeholder(isLoading: true),
            errorWidget: (context, url, error) {
              // debugPrint('[AppNetworkImage] ❌ Error loading: $url');
              // debugPrint('[AppNetworkImage] Error: $error');
              return _placeholder(isError: true, errorMsg: error.toString());
            },
          )
        : _placeholder(isEmpty: true);

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }
    return widget;
  }

  Widget _placeholder({
    bool isLoading = false,
    bool isError = false,
    bool isEmpty = false,
    String? errorMsg,
  }) {
    IconData icon;
    Color iconColor;
    
    if (isLoading) {
      icon = Icons.image_outlined;
      iconColor = AppColors.outline;
    } else if (isError) {
      icon = Icons.broken_image_outlined;
      iconColor = Colors.red.shade300;
    } else {
      icon = Icons.image_not_supported_outlined;
      iconColor = AppColors.muted;
    }
    
    return Container(
      width: width,
      height: height,
      color: AppColors.muted.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          if (isError && errorMsg != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Load failed',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
