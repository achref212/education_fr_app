import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/delf_section_submit_result.dart';
import '../entities/delf_test_history.dart';
import '../entities/delf_test_results.dart';
import '../entities/delf_test_session.dart';

class DelfTestAnswer {
  const DelfTestAnswer({
    required this.questionId,
    required this.selectedIndex,
    this.timeMs = 0,
  });

  final String questionId;
  final int selectedIndex;
  final int timeMs;
}

abstract class DelfTestRepository {
  Future<Either<Failure, DelfTestSession>> startTest();
  Future<Either<Failure, DelfTestSession?>> getActiveTest();
  Future<Either<Failure, List<DelfTestHistory>>> getHistory();
  Future<Either<Failure, DelfSectionSubmitResult>> submitSection({
    required String sessionId,
    required String category,
    required List<DelfTestAnswer> answers,
  });
  Future<Either<Failure, DelfTestResults>> finishTest(String sessionId);
  Future<Either<Failure, DelfTestResults>> getResults(String sessionId);
}
