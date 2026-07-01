import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_theme_mode_use_case.dart';
import '../../domain/usecases/set_theme_mode_use_case.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({
    required GetThemeModeUseCase getThemeMode,
    required SetThemeModeUseCase setThemeMode,
  })  : _getThemeMode = getThemeMode,
        _setThemeMode = setThemeMode,
        super(ThemeMode.system);

  final GetThemeModeUseCase _getThemeMode;
  final SetThemeModeUseCase _setThemeMode;

  Future<void> loadSavedTheme() async {
    final mode = await _getThemeMode();
    emit(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _setThemeMode(mode);
    emit(mode);
  }

  void toggleTheme() {
    final next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    setTheme(next);
  }

  /// Cycles only between Light and Dark (skips System).
  void toggleLightDark() {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }
}
