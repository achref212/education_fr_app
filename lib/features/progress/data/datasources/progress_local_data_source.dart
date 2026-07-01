import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_model.dart';

abstract class ProgressLocalDataSource {
  Future<ProgressModel?> getCachedProgress();
  Future<void> cacheProgress(ProgressModel progress);
  Future<void> clearProgress();
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  ProgressLocalDataSourceImpl(this._prefs);

  static const String _progressKey = 'cached_progress';

  final SharedPreferences _prefs;

  @override
  Future<ProgressModel?> getCachedProgress() async {
    final json = _prefs.getString(_progressKey);
    if (json == null) return null;
    return ProgressModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheProgress(ProgressModel progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  @override
  Future<void> clearProgress() async {
    await _prefs.remove(_progressKey);
  }
}
