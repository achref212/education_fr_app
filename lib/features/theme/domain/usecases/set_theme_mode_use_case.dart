import 'package:flutter/material.dart';

import '../repositories/theme_repository.dart';

class SetThemeModeUseCase {
  SetThemeModeUseCase(this._repository);

  final ThemeRepository _repository;

  Future<void> call(ThemeMode mode) => _repository.saveThemeMode(mode);
}
