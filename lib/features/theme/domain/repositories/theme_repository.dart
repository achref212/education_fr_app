import 'package:flutter/material.dart';

/// Contract for persisting and reading the user's preferred theme mode.
abstract class ThemeRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
