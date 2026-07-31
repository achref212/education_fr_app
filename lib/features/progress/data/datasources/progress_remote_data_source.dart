import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/progress_model.dart';

abstract class ProgressRemoteDataSource {
  Future<ProgressModel> getProgress();
  Future<void> saveProgress(ProgressModel progress);
  Future<void> completeLesson(String lessonId);
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  ProgressRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProgressModel> getProgress() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.progress);
    return ProgressModel.fromJson(response.data!);
  }

  @override
  Future<void> saveProgress(ProgressModel progress) async {
    await _dio.put<void>(
      ApiConstants.progress,
      data: progress.toJson(),
    );
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    await _dio.post<void>(ApiConstants.progressLessonComplete(lessonId));
  }
}
