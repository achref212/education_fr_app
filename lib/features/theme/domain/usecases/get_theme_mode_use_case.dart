import 'package:flutter/material.dart';

import '../repositories/theme_repository.dart';

class GetThemeModeUseCase {
  GetThemeModeUseCase(this._repository);

  final ThemeRepository _repository;

  Future<ThemeMode> call() => _repository.getThemeMode();
}
