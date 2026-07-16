import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/delf_test_history.dart';
import '../repositories/delf_test_repository.dart';

class GetDelfHistoryUseCase implements UseCase<List<DelfTestHistory>, NoParams> {
  GetDelfHistoryUseCase(this._repository);

  final DelfTestRepository _repository;

  @override
  Future<Either<Failure, List<DelfTestHistory>>> call(NoParams params) =>
      _repository.getHistory();
}
