class StudentDelfMockExam {
  const StudentDelfMockExam({
    required this.id,
    required this.track,
    required this.level,
    required this.title,
    required this.status,
    required this.totalDurationMinutes,
    required this.totalPoints,
    required this.sections,
    required this.assets,
    this.description,
    this.sourceNotes,
  });

  final String id;
  final String track;
  final String level;
  final String title;
  final String? description;
  final String status;
  final int totalDurationMinutes;
  final int totalPoints;
  final String? sourceNotes;
  final List<StudentDelfMockSection> sections;
  final List<StudentDelfMockAsset> assets;

  factory StudentDelfMockExam.fromJson(Map<String, dynamic> json) =>
      StudentDelfMockExam(
        id: json['id']?.toString() ?? '',
        track: json['track']?.toString() ?? '',
        level: json['level']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        status: json['status']?.toString() ?? '',
        totalDurationMinutes: _int(json['totalDurationMinutes']),
        totalPoints: _int(json['totalPoints'], fallback: 100),
        sourceNotes: json['sourceNotes']?.toString(),
        sections: _jsonList(json['sections'])
            .map(StudentDelfMockSection.fromJson)
            .toList(),
        assets: _jsonList(json['assets'])
            .map(StudentDelfMockAsset.fromJson)
            .toList(),
      );
}

class StudentDelfMockSection {
  const StudentDelfMockSection({
    required this.id,
    required this.examId,
    required this.sectionOrder,
    required this.sectionType,
    required this.title,
    required this.durationMinutes,
    required this.points,
    required this.instructions,
    required this.rubric,
    required this.metadata,
    required this.items,
    this.audioUrl,
  });

  final String id;
  final String examId;
  final int sectionOrder;
  final String sectionType;
  final String title;
  final int durationMinutes;
  final int points;
  final String instructions;
  final String? audioUrl;
  final Map<String, dynamic> rubric;
  final Map<String, dynamic> metadata;
  final List<StudentDelfMockItem> items;

  factory StudentDelfMockSection.fromJson(Map<String, dynamic> json) =>
      StudentDelfMockSection(
        id: json['id']?.toString() ?? '',
        examId: json['examId']?.toString() ?? '',
        sectionOrder: _int(json['sectionOrder']),
        sectionType: json['sectionType']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        durationMinutes: _int(json['durationMinutes']),
        points: _int(json['points'], fallback: 25),
        instructions: json['instructions']?.toString() ?? '',
        audioUrl: json['audioUrl']?.toString(),
        rubric: _jsonMap(json['rubric']),
        metadata: _jsonMap(json['metadata']),
        items:
            _jsonList(json['items']).map(StudentDelfMockItem.fromJson).toList(),
      );
}

class StudentDelfMockItem {
  const StudentDelfMockItem({
    required this.id,
    required this.sectionId,
    required this.itemOrder,
    required this.title,
    required this.prompt,
    required this.points,
    required this.content,
    required this.answerKey,
    required this.rubric,
    required this.metadata,
  });

  final String id;
  final String sectionId;
  final int itemOrder;
  final String title;
  final String prompt;
  final int points;
  final Map<String, dynamic> content;
  final Map<String, dynamic> answerKey;
  final Map<String, dynamic> rubric;
  final Map<String, dynamic> metadata;

  List<String> get options {
    final raw = content['options'] ?? metadata['options'];
    if (raw is List) {
      return raw.map((dynamic option) => option.toString()).toList();
    }
    return const <String>[];
  }

  bool get isObjective => options.isNotEmpty;

  factory StudentDelfMockItem.fromJson(Map<String, dynamic> json) =>
      StudentDelfMockItem(
        id: json['id']?.toString() ?? '',
        sectionId: json['sectionId']?.toString() ?? '',
        itemOrder: _int(json['itemOrder']),
        title: json['title']?.toString() ?? '',
        prompt: json['prompt']?.toString() ?? '',
        points: _int(json['points']),
        content: _jsonMap(json['content']),
        answerKey: _jsonMap(json['answerKey']),
        rubric: _jsonMap(json['rubric']),
        metadata: _jsonMap(json['metadata']),
      );
}

class StudentDelfMockAsset {
  const StudentDelfMockAsset({
    required this.id,
    required this.examId,
    required this.assetType,
    required this.title,
    required this.url,
    required this.metadata,
  });

  final String id;
  final String examId;
  final String assetType;
  final String title;
  final String url;
  final Map<String, dynamic> metadata;

  factory StudentDelfMockAsset.fromJson(Map<String, dynamic> json) =>
      StudentDelfMockAsset(
        id: json['id']?.toString() ?? '',
        examId: json['examId']?.toString() ?? '',
        assetType: json['assetType']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        metadata: _jsonMap(json['metadata']),
      );
}

class StudentDelfMockAttempt {
  const StudentDelfMockAttempt({
    required this.attemptId,
    required this.examId,
    required this.status,
    required this.answers,
    required this.sectionScores,
    required this.approximate,
    required this.startedAt,
    required this.exam,
    this.overallScore,
    this.resultMessage,
    this.finishedAt,
  });

  final String attemptId;
  final String examId;
  final String status;
  final List<Map<String, dynamic>> answers;
  final Map<String, int> sectionScores;
  final int? overallScore;
  final bool approximate;
  final String? resultMessage;
  final String startedAt;
  final String? finishedAt;
  final StudentDelfMockExam exam;

  factory StudentDelfMockAttempt.fromJson(Map<String, dynamic> json) =>
      StudentDelfMockAttempt(
        attemptId: json['attemptId']?.toString() ?? '',
        examId: json['examId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        answers: _jsonList(json['answers']),
        sectionScores: _jsonMap(json['sectionScores'])
            .map((key, value) => MapEntry(key, _int(value))),
        overallScore:
            json['overallScore'] == null ? null : _int(json['overallScore']),
        approximate: json['approximate'] != false,
        resultMessage: json['resultMessage']?.toString(),
        startedAt: json['startedAt']?.toString() ?? '',
        finishedAt: json['finishedAt']?.toString(),
        exam: StudentDelfMockExam.fromJson(
          (json['exam'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        ),
      );
}

class StudentDelfMockAnswer {
  const StudentDelfMockAnswer({
    required this.itemId,
    this.selectedIndex,
    this.text,
  });

  final String itemId;
  final int? selectedIndex;
  final String? text;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'itemId': itemId,
        if (selectedIndex != null) 'selectedIndex': selectedIndex,
        if (text != null) 'text': text,
      };
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, dynamic item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
