import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/usecases/complete_step_use_case.dart';
import '../models/parcours_model.dart';
import '../models/parcours_summary_model.dart';
import '../models/step_complete_result_model.dart';

abstract class ParcoursRemoteDataSource {
  Future<ParcoursModel> getParcours();
  Future<ParcoursSummaryModel> getParcoursSummary();
  Future<void> startStep(String stepId);
  Future<StepCompleteResultModel> completeStep({
    required String stepId,
    required int score,
    List<StepAnswer> answers,
  });
  Future<void> updateDifficulty(String difficulty);
}

class ParcoursRemoteDataSourceImpl implements ParcoursRemoteDataSource {
  ParcoursRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ParcoursModel> getParcours() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.parcoursMe);
    return ParcoursModel.fromJson(response.data!);
  }

  @override
  Future<ParcoursSummaryModel> getParcoursSummary() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.parcoursSummary);
    return ParcoursSummaryModel.fromJson(response.data!);
  }

  @override
  Future<void> startStep(String stepId) async {
    await _dio.post<void>(ApiConstants.parcoursStepStart(stepId));
  }

  @override
  Future<StepCompleteResultModel> completeStep({
    required String stepId,
    required int score,
    List<StepAnswer> answers = const <StepAnswer>[],
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.parcoursStepComplete(stepId),
      data: <String, dynamic>{
        'score': score,
        if (answers.isNotEmpty)
          'answers':
              answers.map((StepAnswer answer) => answer.toJson()).toList(),
      },
    );
    return StepCompleteResultModel.fromJson(response.data!);
  }

  @override
  Future<void> updateDifficulty(String difficulty) async {
    await _dio.put<void>(
      ApiConstants.parcoursDifficulty,
      data: <String, String>{'difficulty': difficulty},
    );
  }
}
