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

class MultiplayerStudent {
  const MultiplayerStudent({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.classLevel,
    this.gender,
    this.profilePictureUrl,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? classLevel;
  final String? gender;
  final String? profilePictureUrl;

  String get displayName => '$firstName $lastName'.trim();

  factory MultiplayerStudent.fromJson(Map<String, dynamic> json) =>
      MultiplayerStudent(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        classLevel: json['classLevel']?.toString(),
        gender: json['gender']?.toString(),
        profilePictureUrl: json['profilePictureUrl']?.toString(),
      );
}

class MultiplayerRoomRequest {
  const MultiplayerRoomRequest({
    required this.id,
    required this.classLevel,
    required this.participantIds,
    required this.participants,
    required this.status,
    required this.createdAt,
    this.requester,
    this.message,
    this.createdRoomId,
    this.rejectionReason,
  });

  final String id;
  final String classLevel;
  final List<String> participantIds;
  final List<MultiplayerStudent> participants;
  final MultiplayerStudent? requester;
  final String? message;
  final String status;
  final String? createdRoomId;
  final String? rejectionReason;
  final String createdAt;

  factory MultiplayerRoomRequest.fromJson(Map<String, dynamic> json) =>
      MultiplayerRoomRequest(
        id: json['id']?.toString() ?? '',
        classLevel: json['classLevel']?.toString() ?? '',
        participantIds: (json['participantIds'] as List<dynamic>? ?? [])
            .map((dynamic item) => item.toString())
            .toList(),
        participants: _list(json['participants'])
            .map(MultiplayerStudent.fromJson)
            .toList(),
        requester: json['requester'] is Map<String, dynamic>
            ? MultiplayerStudent.fromJson(
                json['requester'] as Map<String, dynamic>,
              )
            : null,
        message: json['message']?.toString(),
        status: json['status']?.toString() ?? 'pending',
        createdRoomId: json['createdRoomId']?.toString(),
        rejectionReason: json['rejectionReason']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
      );
}

class MultiplayerGame {
  const MultiplayerGame({
    required this.slug,
    required this.name,
    required this.minPlayers,
    required this.maxPlayers,
    this.description,
  });

  final String slug;
  final String name;
  final String? description;
  final int minPlayers;
  final int maxPlayers;

  factory MultiplayerGame.fromJson(Map<String, dynamic> json) =>
      MultiplayerGame(
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        minPlayers: _int(json['minPlayers'], fallback: 2),
        maxPlayers: _int(json['maxPlayers'], fallback: 8),
      );
}

class MultiplayerRoom {
  const MultiplayerRoom({
    required this.id,
    required this.roomCode,
    required this.status,
    required this.participantCount,
    this.label,
    this.classLevel,
    this.activeSessionId,
  });

  final String id;
  final String roomCode;
  final String? label;
  final String? classLevel;
  final String status;
  final String? activeSessionId;
  final int participantCount;

  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    final data = _jsonMap(json['data']);
    final participants = data['participants'];
    final participantCount = json['participantCount'] == null
        ? (participants is List ? participants.length : 0)
        : _int(json['participantCount']);
    return MultiplayerRoom(
      id: json['id']?.toString() ?? '',
      roomCode: json['roomCode']?.toString() ?? '',
      label: json['label']?.toString(),
      classLevel: json['classLevel']?.toString() ?? data['classLevel']?.toString(),
      status: data['status']?.toString() ?? json['status']?.toString() ?? 'waiting',
      activeSessionId: json['activeSessionId']?.toString(),
      participantCount: participantCount,
    );
  }
}

class MultiplayerRoomDetail extends MultiplayerRoom {
  const MultiplayerRoomDetail({
    required super.id,
    required super.roomCode,
    required super.status,
    required super.participantCount,
    required this.participants,
    super.label,
    super.classLevel,
    super.activeSessionId,
    this.session,
  });

  final List<MultiplayerStudent> participants;
  final MultiplayerSession? session;

  factory MultiplayerRoomDetail.fromJson(Map<String, dynamic> json) =>
      MultiplayerRoomDetail(
        id: json['id']?.toString() ?? '',
        roomCode: json['roomCode']?.toString() ?? '',
        label: json['label']?.toString(),
        classLevel: json['classLevel']?.toString(),
        status: json['status']?.toString() ?? 'waiting',
        activeSessionId: json['activeSessionId']?.toString(),
        participantCount: (json['participants'] as List<dynamic>? ?? []).length,
        participants: _list(json['participants'])
            .map(MultiplayerStudent.fromJson)
            .toList(),
        session: json['session'] is Map<String, dynamic>
            ? MultiplayerSession.fromJson(json['session'] as Map<String, dynamic>)
            : null,
      );
}

class MultiplayerSession {
  const MultiplayerSession({
    required this.id,
    required this.status,
    required this.currentRound,
    required this.totalRounds,
    required this.difficulty,
  });

  final String id;
  final String status;
  final int currentRound;
  final int totalRounds;
  final String difficulty;

  factory MultiplayerSession.fromJson(Map<String, dynamic> json) =>
      MultiplayerSession(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'waiting',
        currentRound: _int(json['currentRound']),
        totalRounds: _int(json['totalRounds']),
        difficulty: json['difficulty']?.toString() ?? 'medium',
      );
}

class MultiplayerQuestion {
  const MultiplayerQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.round,
    required this.totalRounds,
  });

  final String id;
  final String question;
  final List<String> options;
  final int round;
  final int totalRounds;

  factory MultiplayerQuestion.fromJson(Map<String, dynamic> json) =>
      MultiplayerQuestion(
        id: json['id']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((dynamic item) => item.toString())
            .toList(),
        round: _int(json['round']),
        totalRounds: _int(json['totalRounds']),
      );
}

class MultiplayerLeaderboardEntry {
  const MultiplayerLeaderboardEntry({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.score,
    required this.rank,
    required this.finished,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final int score;
  final int rank;
  final bool finished;

  String get displayName => '$firstName $lastName'.trim();

  factory MultiplayerLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      MultiplayerLeaderboardEntry(
        userId: json['userId']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        score: _int(json['score']),
        rank: _int(json['rank']),
        finished: json['finished'] == true,
      );
}

class MultiplayerSessionState {
  const MultiplayerSessionState({
    required this.session,
    required this.leaderboard,
    this.currentQuestion,
  });

  final MultiplayerSession session;
  final List<MultiplayerLeaderboardEntry> leaderboard;
  final MultiplayerQuestion? currentQuestion;

  factory MultiplayerSessionState.fromJson(Map<String, dynamic> json) =>
      MultiplayerSessionState(
        session: MultiplayerSession.fromJson(
          (json['session'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        ),
        leaderboard: _list(json['leaderboard'])
            .map(MultiplayerLeaderboardEntry.fromJson)
            .toList(),
        currentQuestion: json['currentQuestion'] is Map<String, dynamic>
            ? MultiplayerQuestion.fromJson(
                json['currentQuestion'] as Map<String, dynamic>,
              )
            : null,
      );
}

class MultiplayerSessionStart {
  const MultiplayerSessionStart({
    required this.session,
    required this.questions,
  });

  final MultiplayerSession session;
  final List<MultiplayerQuestion> questions;

  factory MultiplayerSessionStart.fromJson(Map<String, dynamic> json) =>
      MultiplayerSessionStart(
        session: MultiplayerSession.fromJson(
          (json['session'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        ),
        questions: _list(json['questions'])
            .map(MultiplayerQuestion.fromJson)
            .toList(),
      );
}

class MultiplayerAnswerResult {
  const MultiplayerAnswerResult({
    required this.isCorrect,
    required this.points,
    required this.totalScore,
    required this.roundResult,
  });

  final bool isCorrect;
  final int points;
  final int totalScore;
  final Map<String, dynamic> roundResult;

  factory MultiplayerAnswerResult.fromJson(Map<String, dynamic> json) =>
      MultiplayerAnswerResult(
        isCorrect: json['isCorrect'] == true,
        points: _int(json['points']),
        totalScore: _int(json['totalScore']),
        roundResult: _jsonMap(json['roundResult']),
      );
}

class MultiplayerSessionResults {
  const MultiplayerSessionResults({
    required this.session,
    required this.leaderboard,
    this.myResult,
  });

  final MultiplayerSession session;
  final List<MultiplayerLeaderboardEntry> leaderboard;
  final MultiplayerLeaderboardEntry? myResult;

  factory MultiplayerSessionResults.fromJson(Map<String, dynamic> json) =>
      MultiplayerSessionResults(
        session: MultiplayerSession.fromJson(
          (json['session'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        ),
        leaderboard: _list(json['leaderboard'])
            .map(MultiplayerLeaderboardEntry.fromJson)
            .toList(),
        myResult: json['myResult'] is Map<String, dynamic>
            ? MultiplayerLeaderboardEntry.fromJson(
                json['myResult'] as Map<String, dynamic>,
              )
            : null,
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

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}
