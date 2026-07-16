import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/repositories/delf_test_repository.dart';
import '../models/delf_section_submit_result_model.dart';
import '../models/delf_test_history_model.dart';
import '../models/delf_test_results_model.dart';
import '../models/delf_test_session_model.dart';

abstract class DelfTestRemoteDataSource {
  Future<DelfTestSessionModel> startTest();
  Future<DelfTestSessionModel?> getActiveTest();
  Future<List<DelfTestHistoryModel>> getHistory();
  Future<DelfSectionSubmitResultModel> submitSection({
    required String sessionId,
    required String category,
    required List<DelfTestAnswer> answers,
  });
  Future<DelfTestResultsModel> finishTest(String sessionId);
  Future<DelfTestResultsModel> getResults(String sessionId);
}

class DelfTestRemoteDataSourceImpl implements DelfTestRemoteDataSource {
  DelfTestRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DelfTestSessionModel> startTest() async {
    final response =
        await _dio.post<Map<String, dynamic>>(ApiConstants.delfTestsStart);
    return DelfTestSessionModel.fromJson(response.data!);
  }

  @override
  Future<DelfTestSessionModel?> getActiveTest() async {
    final response = await _dio.get<dynamic>(ApiConstants.delfTestsActive);
    final data = response.data;
    if (data == null) return null;
    return DelfTestSessionModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<DelfTestHistoryModel>> getHistory() async {
    final response =
        await _dio.get<List<dynamic>>(ApiConstants.delfTestsHistory);
    return response.data!
        .map(
          (dynamic item) =>
              DelfTestHistoryModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<DelfSectionSubmitResultModel> submitSection({
    required String sessionId,
    required String category,
    required List<DelfTestAnswer> answers,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.delfTestSectionSubmit(sessionId, category),
      data: <String, List<Map<String, dynamic>>>{
        'answers': answers
            .map(
              (DelfTestAnswer a) => <String, dynamic>{
                'questionId': a.questionId,
                'selectedIndex': a.selectedIndex,
                'timeMs': a.timeMs,
              },
            )
            .toList(),
      },
    );
    return DelfSectionSubmitResultModel.fromJson(response.data!);
  }

  @override
  Future<DelfTestResultsModel> finishTest(String sessionId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.delfTestFinish(sessionId),
    );
    return DelfTestResultsModel.fromJson(response.data!);
  }

  @override
  Future<DelfTestResultsModel> getResults(String sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.delfTestResults(sessionId),
    );
    return DelfTestResultsModel.fromJson(response.data!);
  }
}
