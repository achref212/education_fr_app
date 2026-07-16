import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/delf_test_session.dart';
import '../repositories/delf_test_repository.dart';

class StartDelfTestUseCase implements UseCase<DelfTestSession, NoParams> {
  StartDelfTestUseCase(this._repository);

  final DelfTestRepository _repository;

  @override
  Future<Either<Failure, DelfTestSession>> call(NoParams params) =>
      _repository.startTest();
}
