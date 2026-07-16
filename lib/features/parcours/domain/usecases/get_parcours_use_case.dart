import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/parcours.dart';
import '../repositories/parcours_repository.dart';

class GetParcoursUseCase implements UseCase<Parcours, NoParams> {
  GetParcoursUseCase(this._repository);

  final ParcoursRepository _repository;

  @override
  Future<Either<Failure, Parcours>> call(NoParams params) =>
      _repository.getParcours();
}
