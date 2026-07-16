import 'package:flutter/material.dart';

/// Design tokens extracted directly from the Figma "Speaker" UI Kit.
abstract class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0058B7);
  static const Color primaryLight = Color(0xFF51A8FF);
  static const Color accent = Color(0xFFFFB800);
  static const Color accentPink = Color(0xFFFF4D8D);
  static const Color accentPurple = Color(0xFF7C5CFF);
  static const Color accentMint = Color(0xFF2ED3B7);

  // ── Light Mode ───────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF7FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F6FF);
  static const Color lightSurfacePrimary = Color(0xFFE6F2FF);
  static const Color lightBodyPrimary = Color(0xFF131313);
  static const Color lightBodySecondary = Color(0xFF6C6C6C);
  static const Color lightDivider = Color(0xFFE3EAF4);

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121B2E);
  static const Color darkSurface = Color(0xFF1B2940);
  static const Color darkSurfaceElevated = Color(0xFF243653);
  static const Color darkSurfacePrimary = Color(0xFF123E69);
  static const Color darkBodyPrimary = Color(0xFFF7FAFF);
  static const Color darkBodySecondary = Color(0xFFB5C2D6);
  static const Color darkDivider = Color(0xFF354A67);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD53F36);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);

  // ── On-surface ────────────────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
}
