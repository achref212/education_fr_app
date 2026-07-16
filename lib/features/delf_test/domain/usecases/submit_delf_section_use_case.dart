import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/delf_section_submit_result.dart';
import '../repositories/delf_test_repository.dart';

class SubmitDelfSectionParams extends Equatable {
  const SubmitDelfSectionParams({
    required this.sessionId,
    required this.category,
    required this.answers,
  });

  final String sessionId;
  final String category;
  final List<DelfTestAnswer> answers;

  @override
  List<Object?> get props => [sessionId, category, answers];
}

class SubmitDelfSectionUseCase
    implements UseCase<DelfSectionSubmitResult, SubmitDelfSectionParams> {
  SubmitDelfSectionUseCase(this._repository);

  final DelfTestRepository _repository;

  @override
  Future<Either<Failure, DelfSectionSubmitResult>> call(
    SubmitDelfSectionParams params,
  ) =>
      _repository.submitSection(
        sessionId: params.sessionId,
        category: params.category,
        answers: params.answers,
      );
}
