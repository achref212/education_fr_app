import 'package:flutter/material.dart';

/// Design tokens extracted directly from the Figma "Speaker" UI Kit.
abstract class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0058B7);

  // ── Light Mode ───────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F8F8);
  static const Color lightSurfacePrimary = Color(0xFFE5F2FF);
  static const Color lightBodyPrimary = Color(0xFF131313);
  static const Color lightBodySecondary = Color(0xFF6C6C6C);
  static const Color lightDivider = Color(0xFFE5E5E5);

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF131313);
  static const Color darkSurface = Color(0xFF262626);
  static const Color darkSurfacePrimary = Color(0xFF00254C);
  static const Color darkBodyPrimary = Color(0xFFFFFFFF);
  static const Color darkBodySecondary = Color(0xFF8E8E93);
  static const Color darkDivider = Color(0xFF3A3A3C);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD53F36);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);

  // ── On-surface ────────────────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
}
