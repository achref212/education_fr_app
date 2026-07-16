import 'package:flutter/material.dart';

import '../../domain/entities/parcours_step.dart';
import 'parcours_node.dart';

class ParcoursPathPreview extends StatelessWidget {
  const ParcoursPathPreview({
    super.key,
    required this.steps,
    this.maxSteps = 6,
    this.onStepTap,
  });

  final List<ParcoursStep> steps;
  final int maxSteps;
  final void Function(ParcoursStep step)? onStepTap;

  @override
  Widget build(BuildContext context) {
    final List<ParcoursStep> previewSteps = _buildPreviewSteps();
    return Column(
      children: List<Widget>.generate(previewSteps.length, (int index) {
        final ParcoursStep step = previewSteps[index];
        return ParcoursNode(
          step: step,
          isLast: index == previewSteps.length - 1,
          animationDelay: Duration(milliseconds: index * 80),
          onTap: onStepTap == null ? null : () => onStepTap!(step),
        );
      }),
    );
  }

  List<ParcoursStep> _buildPreviewSteps() {
    final int startIndex = steps.indexWhere(
      (ParcoursStep s) => s.isAvailable || s.isInProgress,
    );
    if (startIndex == -1) {
      final int fromEnd = steps.length > maxSteps ? steps.length - maxSteps : 0;
      return steps.sublist(fromEnd).take(maxSteps).toList();
    }
    final int end = (startIndex + maxSteps).clamp(0, steps.length);
    return steps.sublist(startIndex, end);
  }
}
