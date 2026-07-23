import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/delf_mock_exam_models.dart';

@RoutePage()
class DelfMockExamAttemptScreen extends StatefulWidget {
  const DelfMockExamAttemptScreen({
    super.key,
    @PathParam('attemptId') required this.attemptId,
  });

  final String attemptId;

  @override
  State<DelfMockExamAttemptScreen> createState() =>
      _DelfMockExamAttemptScreenState();
}

class _DelfMockExamAttemptScreenState extends State<DelfMockExamAttemptScreen> {
  late Future<StudentDelfMockAttempt> _future;
  final Map<String, int> _selected = <String, int>{};
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  int _index = 0;
  bool _submitting = false;

  StudentRemoteDataSource get _dataSource => sl<StudentRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _future = _dataSource.getDelfMockAttempt(widget.attemptId);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Examen blanc')),
      body: FutureBuilder<StudentDelfMockAttempt>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Tentative introuvable.'));
          }
          final attempt = snapshot.data!;
          final entries = _entries(attempt.exam);
          if (entries.isEmpty) {
            return const Center(child: Text('Aucun exercice disponible.'));
          }
          final current = entries[_index];
          final item = current.item;
          final section = current.section;
          final progress = (_index + 1) / entries.length;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProgressHeader(
                    section: section,
                    current: _index + 1,
                    total: entries.length,
                    progress: progress,
                  ),
                  const SizedBox(height: 14),
                  if (resolveMediaUrl(section.audioUrl).isNotEmpty)
                    _AudioNotice(url: resolveMediaUrl(section.audioUrl)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _QuestionCard(
                        section: section,
                        item: item,
                        selectedIndex: _selected[item.id],
                        controller: _controllerFor(item.id),
                        onSelected: (index) =>
                            setState(() => _selected[item.id] = index),
                        onTextChanged: () => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _canContinue(item)
                        ? () => _handleNext(attempt, entries)
                        : null,
                    icon: Icon(
                      _index < entries.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      _submitting
                          ? 'Calcul du score...'
                          : _index < entries.length - 1
                              ? 'Continuer'
                              : 'Terminer et voir mon score',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextEditingController _controllerFor(String itemId) {
    return _controllers.putIfAbsent(itemId, TextEditingController.new);
  }

  bool _canContinue(StudentDelfMockItem item) {
    if (_submitting) return false;
    if (item.isObjective) return _selected.containsKey(item.id);
    return _controllerFor(item.id).text.trim().isNotEmpty;
  }

  Future<void> _handleNext(
    StudentDelfMockAttempt attempt,
    List<_AttemptEntry> entries,
  ) async {
    if (_index < entries.length - 1) {
      setState(() => _index++);
      return;
    }
    setState(() => _submitting = true);
    final answers = entries.map((entry) {
      final item = entry.item;
      return StudentDelfMockAnswer(
        itemId: item.id,
        selectedIndex: _selected[item.id],
        text: item.isObjective ? null : _controllerFor(item.id).text.trim(),
      );
    }).toList();
    final submitted = await _dataSource.submitDelfMockAttempt(
      attemptId: attempt.attemptId,
      answers: answers,
    );
    if (!mounted) return;
    await context.router.replace(
      DelfMockExamResultRoute(attemptId: submitted.attemptId),
    );
  }

  List<_AttemptEntry> _entries(StudentDelfMockExam exam) {
    return [
      for (final section in exam.sections)
        for (final item in section.items) _AttemptEntry(section, item),
    ];
  }
}

class _AttemptEntry {
  const _AttemptEntry(this.section, this.item);

  final StudentDelfMockSection section;
  final StudentDelfMockItem item;
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.section,
    required this.current,
    required this.total,
    required this.progress,
  });

  final StudentDelfMockSection section;
  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                section.title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text('$current/$total', style: AppTextStyles.calloutBold),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress.clamp(0, 1),
          minHeight: 9,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}

class _AudioNotice extends StatelessWidget {
  const _AudioNotice({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.headphones_rounded, color: AppColors.accentMint),
          const SizedBox(width: 10),
          Expanded(child: Text('Audio: $url')),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.section,
    required this.item,
    required this.selectedIndex,
    required this.controller,
    required this.onSelected,
    required this.onTextChanged,
  });

  final StudentDelfMockSection section;
  final StudentDelfMockItem item;
  final int? selectedIndex;
  final TextEditingController controller;
  final ValueChanged<int> onSelected;
  final VoidCallback onTextChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.instructions, style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(item.prompt, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 18),
          if (item.isObjective)
            for (int index = 0; index < item.options.length; index++) ...[
              _OptionTile(
                text: item.options[index],
                index: index,
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
              const SizedBox(height: 10),
            ]
          else
            TextField(
              controller: controller,
              minLines: section.sectionType == 'speaking' ? 4 : 6,
              maxLines: 10,
              onChanged: (_) => onTextChanged(),
              decoration: InputDecoration(
                labelText: section.sectionType == 'speaking'
                    ? 'Ma réponse orale préparée'
                    : 'Ma réponse écrite',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightDivider,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  selected ? AppColors.primary : Colors.transparent,
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
