class StudentHub {
  const StudentHub({
    required this.firstName,
    required this.lastName,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.completedSteps,
    required this.totalSteps,
    required this.parcoursPercent,
    required this.reviewOpenCount,
    required this.weakCategories,
    required this.achievementsPreview,
    required this.nextAction,
    this.classLevel,
    this.profilePictureUrl,
    this.nextStepId,
    this.nextStepTitle,
    this.recentDelf,
  });

  final String firstName;
  final String lastName;
  final String? classLevel;
  final String? profilePictureUrl;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int completedSteps;
  final int totalSteps;
  final double parcoursPercent;
  final String? nextStepId;
  final String? nextStepTitle;
  final int reviewOpenCount;
  final List<StudentWeakCategory> weakCategories;
  final StudentRecentDelf? recentDelf;
  final List<StudentAchievement> achievementsPreview;
  final StudentNextAction nextAction;

  factory StudentHub.fromJson(Map<String, dynamic> json) => StudentHub(
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        classLevel: json['classLevel']?.toString(),
        profilePictureUrl: json['profilePictureUrl']?.toString(),
        totalXp: _int(json['totalXp']),
        currentStreak: _int(json['currentStreak']),
        longestStreak: _int(json['longestStreak']),
        level: _int(json['level'], fallback: 1),
        completedSteps: _int(json['completedSteps']),
        totalSteps: _int(json['totalSteps']),
        parcoursPercent: _double(json['parcoursPercent']),
        nextStepId: json['nextStepId']?.toString(),
        nextStepTitle: json['nextStepTitle']?.toString(),
        reviewOpenCount: _int(json['reviewOpenCount']),
        weakCategories: _list(json['weakCategories'])
            .map(StudentWeakCategory.fromJson)
            .toList(),
        recentDelf: json['recentDelf'] is Map<String, dynamic>
            ? StudentRecentDelf.fromJson(
                json['recentDelf'] as Map<String, dynamic>)
            : null,
        achievementsPreview: _list(json['achievementsPreview'])
            .map(StudentAchievement.fromJson)
            .toList(),
        nextAction: StudentNextAction.fromJson(
          (json['nextAction'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        ),
      );
}

class StudentNextAction {
  const StudentNextAction({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
    this.itemId,
  });

  final String type;
  final String title;
  final String subtitle;
  final String route;
  final String? itemId;

  factory StudentNextAction.fromJson(Map<String, dynamic> json) =>
      StudentNextAction(
        type: json['type']?.toString() ?? 'parcours',
        title: json['title']?.toString() ?? 'Continuer',
        subtitle: json['subtitle']?.toString() ?? '',
        route: json['route']?.toString() ?? 'parcours',
        itemId: json['itemId']?.toString(),
      );
}

class StudentWeakCategory {
  const StudentWeakCategory({required this.category, required this.count});

  final String category;
  final int count;

  factory StudentWeakCategory.fromJson(Map<String, dynamic> json) =>
      StudentWeakCategory(
        category: json['category']?.toString() ?? '',
        count: _int(json['count']),
      );
}

class StudentRecentDelf {
  const StudentRecentDelf({
    required this.sessionId,
    required this.targetDelfLevel,
    required this.categoryScores,
    this.achievedDelfLevel,
    this.overallScore,
    this.finishedAt,
  });

  final String sessionId;
  final String targetDelfLevel;
  final String? achievedDelfLevel;
  final int? overallScore;
  final Map<String, int> categoryScores;
  final String? finishedAt;

  factory StudentRecentDelf.fromJson(Map<String, dynamic> json) =>
      StudentRecentDelf(
        sessionId: json['sessionId']?.toString() ?? '',
        targetDelfLevel: json['targetDelfLevel']?.toString() ?? '',
        achievedDelfLevel: json['achievedDelfLevel']?.toString(),
        overallScore:
            json['overallScore'] == null ? null : _int(json['overallScore']),
        categoryScores: (json['categoryScores'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, _int(value))),
        finishedAt: json['finishedAt']?.toString(),
      );
}

class StudentReview {
  const StudentReview({
    required this.totalOpen,
    required this.totalCompleted,
    required this.weakCategories,
    required this.groups,
  });

  final int totalOpen;
  final int totalCompleted;
  final List<StudentWeakCategory> weakCategories;
  final List<StudentReviewGroup> groups;

  List<StudentReviewItem> get openItems =>
      groups.expand((StudentReviewGroup group) => group.items).toList();

  factory StudentReview.fromJson(Map<String, dynamic> json) => StudentReview(
        totalOpen: _int(json['totalOpen']),
        totalCompleted: _int(json['totalCompleted']),
        weakCategories: _list(json['weakCategories'])
            .map(StudentWeakCategory.fromJson)
            .toList(),
        groups: _list(json['groups']).map(StudentReviewGroup.fromJson).toList(),
      );
}

class StudentReviewGroup {
  const StudentReviewGroup({
    required this.category,
    required this.total,
    required this.openCount,
    required this.items,
  });

  final String category;
  final int total;
  final int openCount;
  final List<StudentReviewItem> items;

  factory StudentReviewGroup.fromJson(Map<String, dynamic> json) =>
      StudentReviewGroup(
        category: json['category']?.toString() ?? '',
        total: _int(json['total']),
        openCount: _int(json['openCount']),
        items: _list(json['items']).map(StudentReviewItem.fromJson).toList(),
      );
}

class StudentReviewItem {
  const StudentReviewItem({
    required this.id,
    required this.sourceType,
    required this.category,
    required this.question,
    required this.options,
    required this.status,
    required this.timesReviewed,
    this.sourceId,
    this.questionId,
    this.selectedIndex,
    this.correctIndex,
    this.explanation,
  });

  final String id;
  final String sourceType;
  final String? sourceId;
  final String? questionId;
  final String category;
  final String question;
  final List<String> options;
  final int? selectedIndex;
  final int? correctIndex;
  final String? explanation;
  final String status;
  final int timesReviewed;

  String? get selectedAnswer => _answerAt(selectedIndex);
  String? get correctAnswer => _answerAt(correctIndex);

  String? _answerAt(int? index) {
    if (index == null || index < 0 || index >= options.length) return null;
    return options[index];
  }

  factory StudentReviewItem.fromJson(Map<String, dynamic> json) =>
      StudentReviewItem(
        id: json['id']?.toString() ?? '',
        sourceType: json['sourceType']?.toString() ?? '',
        sourceId: json['sourceId']?.toString(),
        questionId: json['questionId']?.toString(),
        category: json['category']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        options: (json['options'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic item) => item.toString())
            .toList(),
        selectedIndex:
            json['selectedIndex'] == null ? null : _int(json['selectedIndex']),
        correctIndex:
            json['correctIndex'] == null ? null : _int(json['correctIndex']),
        explanation: json['explanation']?.toString(),
        status: json['status']?.toString() ?? 'open',
        timesReviewed: _int(json['timesReviewed']),
      );
}

class StudentHint {
  const StudentHint({
    required this.itemId,
    required this.hint,
    required this.source,
  });

  final String itemId;
  final String hint;
  final String source;

  factory StudentHint.fromJson(Map<String, dynamic> json) => StudentHint(
        itemId: json['itemId']?.toString() ?? '',
        hint: json['hint']?.toString() ?? '',
        source: json['source']?.toString() ?? 'fallback',
      );
}

class StudentLeaderboard {
  const StudentLeaderboard({
    required this.scope,
    required this.entries,
    this.currentRank,
    this.currentStudent,
  });

  final String scope;
  final int? currentRank;
  final StudentLeaderboardEntry? currentStudent;
  final List<StudentLeaderboardEntry> entries;

  factory StudentLeaderboard.fromJson(Map<String, dynamic> json) =>
      StudentLeaderboard(
        scope: json['scope']?.toString() ?? 'class',
        currentRank:
            json['currentRank'] == null ? null : _int(json['currentRank']),
        currentStudent: json['currentStudent'] is Map<String, dynamic>
            ? StudentLeaderboardEntry.fromJson(
                json['currentStudent'] as Map<String, dynamic>,
              )
            : null,
        entries: _list(json['entries'])
            .map(StudentLeaderboardEntry.fromJson)
            .toList(),
      );
}

class StudentLeaderboardEntry {
  const StudentLeaderboardEntry({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.totalXp,
    required this.currentStreak,
    required this.completedSteps,
    required this.progressPercent,
    required this.rank,
    required this.isCurrentUser,
    this.classLevel,
    this.profilePictureUrl,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String? classLevel;
  final String? profilePictureUrl;
  final int totalXp;
  final int currentStreak;
  final int completedSteps;
  final double progressPercent;
  final int rank;
  final bool isCurrentUser;

  factory StudentLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      StudentLeaderboardEntry(
        userId: json['userId']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        classLevel: json['classLevel']?.toString(),
        profilePictureUrl: json['profilePictureUrl']?.toString(),
        totalXp: _int(json['totalXp']),
        currentStreak: _int(json['currentStreak']),
        completedSteps: _int(json['completedSteps']),
        progressPercent: _double(json['progressPercent']),
        rank: _int(json['rank']),
        isCurrentUser: json['isCurrentUser'] == true,
      );
}

class StudentAchievements {
  const StudentAchievements({
    required this.unlockedCount,
    required this.totalCount,
    required this.items,
    this.nextBadge,
  });

  final int unlockedCount;
  final int totalCount;
  final StudentAchievement? nextBadge;
  final List<StudentAchievement> items;

  factory StudentAchievements.fromJson(Map<String, dynamic> json) =>
      StudentAchievements(
        unlockedCount: _int(json['unlockedCount']),
        totalCount: _int(json['totalCount']),
        nextBadge: json['nextBadge'] is Map<String, dynamic>
            ? StudentAchievement.fromJson(
                json['nextBadge'] as Map<String, dynamic>,
              )
            : null,
        items: _list(json['items']).map(StudentAchievement.fromJson).toList(),
      );
}

class StudentAchievement {
  const StudentAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.progress,
    required this.target,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final int progress;
  final int target;
  final String category;

  double get percent => target == 0 ? 0 : progress / target;

  factory StudentAchievement.fromJson(Map<String, dynamic> json) =>
      StudentAchievement(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        icon: json['icon']?.toString() ?? 'award',
        unlocked: json['unlocked'] == true,
        progress: _int(json['progress']),
        target: _int(json['target'], fallback: 1),
        category: json['category']?.toString() ?? '',
      );
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _double(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
