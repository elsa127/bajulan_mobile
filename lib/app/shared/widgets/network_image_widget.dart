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
    final widget = url != null && url!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _placeholder(),
          )
        : _placeholder();

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }
    return widget;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.muted.withValues(alpha: 0.3),
      child: const Icon(Icons.image_outlined, color: AppColors.outline),
    );
  }
}
