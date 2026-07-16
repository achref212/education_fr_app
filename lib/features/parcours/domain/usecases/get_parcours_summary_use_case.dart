import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/parcours_summary.dart';
import '../repositories/parcours_repository.dart';

class GetParcoursSummaryUseCase implements UseCase<ParcoursSummary, NoParams> {
  GetParcoursSummaryUseCase(this._repository);

  final ParcoursRepository _repository;

  @override
  Future<Either<Failure, ParcoursSummary>> call(NoParams params) =>
      _repository.getParcoursSummary();
}
