import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/delf_test_results.dart';
import '../repositories/delf_test_repository.dart';

class FinishDelfTestParams extends Equatable {
  const FinishDelfTestParams({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class FinishDelfTestUseCase implements UseCase<DelfTestResults, FinishDelfTestParams> {
  FinishDelfTestUseCase(this._repository);

  final DelfTestRepository _repository;

  @override
  Future<Either<Failure, DelfTestResults>> call(FinishDelfTestParams params) =>
      _repository.finishTest(params.sessionId);
}
