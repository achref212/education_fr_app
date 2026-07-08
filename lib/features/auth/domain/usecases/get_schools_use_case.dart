import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/school.dart';
import '../repositories/auth_repository.dart';

class GetSchoolsUseCase implements UseCase<List<School>, NoParams> {
  GetSchoolsUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, List<School>>> call(NoParams params) =>
      _repository.getSchools();
}
