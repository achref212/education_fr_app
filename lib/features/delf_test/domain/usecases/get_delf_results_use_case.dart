import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/delf_test_results.dart';
import '../repositories/delf_test_repository.dart';

class GetDelfResultsParams extends Equatable {
  const GetDelfResultsParams({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class GetDelfResultsUseCase implements UseCase<DelfTestResults, GetDelfResultsParams> {
  GetDelfResultsUseCase(this._repository);

  final DelfTestRepository _repository;

  @override
  Future<Either<Failure, DelfTestResults>> call(GetDelfResultsParams params) =>
      _repository.getResults(params.sessionId);
}
