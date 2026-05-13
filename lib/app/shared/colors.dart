import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Colors ───────────────────────────────────────
  static const primary = Color(0xFF2D4236);
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFF8C6A43);
  static const onSecondary = Colors.white;
  static const tertiary = Color(0xFFD4AF37);
  static const onTertiary = Colors.white;

  // ── Surface & Background ───────────────────────────────
  static const background = Color(0xFFF5F0E8);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1C1C19);
  static const surfaceVariant = Color(0xFFF0EDE9);

  // ── Text ───────────────────────────────────────────────
  static const outline = Color(0xFF737873);
  static const muted = Color(0xFFC2C8C2);

  // ── Status ─────────────────────────────────────────────
  static const error = Color(0xFFBA1A1A);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const info = Color(0xFF2563EB);

  // ── Typography ─────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    color: primary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleMedium = TextStyle(
    color: primary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleSmall = TextStyle(
    color: primary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle bodyLarge = TextStyle(
    color: onSurface,
    fontSize: 14,
  );
  static const TextStyle bodyMedium = TextStyle(
    color: onSurface,
    fontSize: 13,
  );
  static const TextStyle bodySmall = TextStyle(
    color: outline,
    fontSize: 12,
  );
  static const TextStyle labelBold = TextStyle(
    color: primary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // ── Spacing ────────────────────────────────────────────
  static const double spaceXs = 4;
  static const double spaceS = 8;
  static const double spaceM = 12;
  static const double spaceL = 16;
  static const double spaceXl = 20;
  static const double space2xl = 24;

  // ── Border Radius ──────────────────────────────────────
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXl = 20;

  // ── Card Decoration ────────────────────────────────────
  static BoxDecoration cardDecoration({double radius = radiusXl}) =>
      BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  // ── Input Decoration ───────────────────────────────────
  static BoxDecoration inputDecoration = BoxDecoration(
    color: surfaceVariant,
    borderRadius: BorderRadius.circular(radiusM),
  );
}
