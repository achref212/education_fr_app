import 'package:flutter/material.dart';

import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._localDataSource);

  final ThemeLocalDataSource _localDataSource;

  @override
  Future<ThemeMode> getThemeMode() async => _localDataSource.getThemeMode();

  @override
  Future<void> saveThemeMode(ThemeMode mode) =>
      _localDataSource.saveThemeMode(mode);
}
