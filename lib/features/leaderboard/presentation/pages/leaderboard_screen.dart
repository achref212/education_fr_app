import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/presentation/auth_constants.dart';
import '../../../profile/presentation/widgets/circular_profile_avatar.dart';
import '../../../student/data/datasources/student_remote_data_source.dart';
import '../../../student/domain/entities/student_models.dart';

@RoutePage()
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _tab = 'ranking';
  String _scope = 'class';
  String _difficulty = 'medium';
  late Future<StudentLeaderboard> _leaderboardFuture;
  late Future<List<MultiplayerRoom>> _roomsFuture;
  late Future<_RequestData> _requestFuture;

  StudentRemoteDataSource get _dataSource => sl<StudentRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _dataSource.getLeaderboard(_scope);
    _roomsFuture = _dataSource.getMyMultiplayerRooms();
    _requestFuture = _loadRequestData();
  }

  Future<_RequestData> _loadRequestData() async => _RequestData(
        classmates: await _dataSource.getClassmates(),
        requests: await _dataSource.getMultiplayerRequests(),
      );

  void _loadLeaderboard(String scope) {
    setState(() {
      _scope = scope;
      _leaderboardFuture = _dataSource.getLeaderboard(scope);
    });
  }

  void _reloadRooms() {
    if (!mounted) return;
    setState(() => _roomsFuture = _dataSource.getMyMultiplayerRooms());
  }

  void _reloadRequests() {
    if (!mounted) return;
    setState(() => _requestFuture = _loadRequestData());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Classement multijoueur'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_tab == 'ranking') {
            _loadLeaderboard(_scope);
            await _leaderboardFuture;
          } else if (_tab == 'rooms') {
            _reloadRooms();
            await _roomsFuture;
          } else {
            _reloadRequests();
            await _requestFuture;
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'ranking',
                  label: Text('Classement'),
                  icon: Icon(Icons.emoji_events_rounded),
                ),
                ButtonSegment(
                  value: 'rooms',
                  label: Text('Mes salles'),
                  icon: Icon(Icons.sports_esports_rounded),
                ),
                ButtonSegment(
                  value: 'request',
                  label: Text('Groupe'),
                  icon: Icon(Icons.group_add_rounded),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (values) =>
                  setState(() => _tab = values.first),
            ),
            const SizedBox(height: 16),
            if (_tab == 'ranking')
              _RankingPanel(
                  future: _leaderboardFuture,
                  scope: _scope,
                  onScopeChanged: _loadLeaderboard),
            if (_tab == 'rooms')
              _RoomsPanel(
                  future: _roomsFuture,
                  onJoin: _joinRoom,
                  onOpen: _openRoom,
                  onReload: _reloadRooms),
            if (_tab == 'request')
              _RequestPanel(
                  future: _requestFuture,
                  onSubmit: _submitRequest,
                  onReload: _reloadRequests),
          ],
        ),
      ),
    );
  }

  Future<void> _joinRoom() async {
    final controller = TextEditingController();
    final String? code;
    try {
      code = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Rejoindre une partie'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Code salle',
              prefixIcon: Icon(Icons.vpn_key_rounded),
            ),
            onSubmitted: (value) =>
                Navigator.of(dialogContext).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Rejoindre'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    final roomCode = code?.trim();
    if (roomCode == null || roomCode.isEmpty || !mounted) return;
    try {
      await _dataSource.joinMultiplayerRoom(roomCode);
      if (!mounted) return;
      _reloadRooms();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salle ajoutée à vos parties.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _submitRequest(List<String> ids, String? message) async {
    await _dataSource.createMultiplayerRequest(
        participantIds: ids, message: message);
    _reloadRequests();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Demande envoyée au professeur et à l’école.')),
    );
  }

  Future<void> _openRoom(MultiplayerRoom room) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RoomSheet(
        roomId: room.id,
        difficulty: _difficulty,
        onDifficultyChanged: (value) => _difficulty = value,
      ),
    );
    if (changed == true) _reloadRooms();
  }
}

class _RankingPanel extends StatelessWidget {
  const _RankingPanel({
    required this.future,
    required this.scope,
    required this.onScopeChanged,
  });

  final Future<StudentLeaderboard> future;
  final String scope;
  final ValueChanged<String> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentLeaderboard>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingBlock();
        }
        if (snapshot.hasError) {
          return const _StateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Classement indisponible',
            subtitle: 'Réessaie dans un instant.',
          );
        }
        final leaderboard = snapshot.data;
        if (leaderboard == null || leaderboard.entries.isEmpty) {
          return const _StateMessage(
            icon: Icons.emoji_events_outlined,
            title: 'Aucun classement',
            subtitle:
                'Les élèves apparaîtront ici dès qu’ils auront gagné des XP.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'class',
                    label: Text('Classe'),
                    icon: Icon(Icons.groups_rounded)),
                ButtonSegment(
                    value: 'school',
                    label: Text('École'),
                    icon: Icon(Icons.school_rounded)),
              ],
              selected: {scope},
              onSelectionChanged: (values) => onScopeChanged(values.first),
            ),
            const SizedBox(height: 16),
            if (leaderboard.currentStudent != null)
              _RankHero(entry: leaderboard.currentStudent!),
            const SizedBox(height: 18),
            Text('Top étudiants',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final entry in leaderboard.entries) ...[
              _LeaderboardTile(entry: entry),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _RoomsPanel extends StatelessWidget {
  const _RoomsPanel({
    required this.future,
    required this.onJoin,
    required this.onOpen,
    required this.onReload,
  });

  final Future<List<MultiplayerRoom>> future;
  final VoidCallback onJoin;
  final ValueChanged<MultiplayerRoom> onOpen;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MultiplayerRoom>>(
      future: future,
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? const <MultiplayerRoom>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Rejoindre avec un code'),
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting)
              const _LoadingBlock()
            else if (snapshot.hasError)
              _RetryBlock(title: 'Salles indisponibles', onRetry: onReload)
            else if (rooms.isEmpty)
              const _StateMessage(
                icon: Icons.sports_esports_outlined,
                title: 'Aucune salle',
                subtitle:
                    'Rejoins une salle avec un code ou demande un groupe.',
              )
            else
              for (final room in rooms) ...[
                _RoomTile(room: room, onTap: () => onOpen(room)),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }
}

class _RequestPanel extends StatefulWidget {
  const _RequestPanel({
    required this.future,
    required this.onSubmit,
    required this.onReload,
  });

  final Future<_RequestData> future;
  final Future<void> Function(List<String>, String?) onSubmit;
  final VoidCallback onReload;

  @override
  State<_RequestPanel> createState() => _RequestPanelState();
}

class _RequestPanelState extends State<_RequestPanel> {
  final Set<String> _selected = <String>{};
  final TextEditingController _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RequestData>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingBlock();
        }
        if (snapshot.hasError) {
          return _RetryBlock(
              title: 'Demandes indisponibles', onRetry: widget.onReload);
        }
        final data =
            snapshot.data ?? const _RequestData(classmates: [], requests: []);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Choisir les élèves',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (data.classmates.length < 2)
              const _StateMessage(
                icon: Icons.group_off_rounded,
                title: 'Classe incomplète',
                subtitle: 'Il faut au moins deux élèves dans la classe.',
              )
            else ...[
              for (final student in data.classmates) ...[
                CheckboxListTile(
                  value: _selected.contains(student.id),
                  onChanged: (checked) => setState(() {
                    if (checked == true) {
                      _selected.add(student.id);
                    } else {
                      _selected.remove(student.id);
                    }
                  }),
                  title: Text(student.displayName),
                  subtitle: Text([
                    if (student.classLevel != null) student.classLevel!,
                    if (student.gender != null)
                      AuthConstants.genders[student.gender] ?? student.gender!,
                  ].join(' • ')),
                  secondary: CircularProfileAvatar(
                    imageUrl: student.profilePictureUrl,
                    initials: student.firstName.isEmpty
                        ? null
                        : student.firstName[0].toUpperCase(),
                    size: 40,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message au professeur (optionnel)',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _selected.length < 2 || _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        try {
                          await widget.onSubmit(
                              _selected.toList(), _messageController.text);
                          _selected.clear();
                          _messageController.clear();
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
                      },
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text('Envoyer la demande'),
              ),
            ],
            const SizedBox(height: 22),
            Text('Mes demandes',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (data.requests.isEmpty)
              const Text('Aucune demande envoyée pour le moment.')
            else
              for (final request in data.requests) ...[
                _RequestTile(request: request),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }
}

class _RoomSheet extends StatefulWidget {
  const _RoomSheet({
    required this.roomId,
    required this.difficulty,
    required this.onDifficultyChanged,
  });

  final String roomId;
  final String difficulty;
  final ValueChanged<String> onDifficultyChanged;

  @override
  State<_RoomSheet> createState() => _RoomSheetState();
}

class _RoomSheetState extends State<_RoomSheet> {
  late Future<MultiplayerRoomDetail> _future;
  late String _difficulty;

  StudentRemoteDataSource get _dataSource => sl<StudentRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _future = _dataSource.getMultiplayerRoom(widget.roomId);
  }

  void _reload() =>
      setState(() => _future = _dataSource.getMultiplayerRoom(widget.roomId));

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      builder: (context, controller) => FutureBuilder<MultiplayerRoomDetail>(
        future: _future,
        builder: (context, snapshot) {
          final room = snapshot.data;
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                const _LoadingBlock()
              else if (snapshot.hasError || room == null)
                _RetryBlock(title: 'Salle indisponible', onRetry: _reload)
              else ...[
                Text(room.label ?? 'Salle ${room.roomCode}',
                    style: AppTextStyles.titleLarge
                        .copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${room.classLevel ?? 'Classe'} • Code ${room.roomCode}'),
                const SizedBox(height: 14),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'easy', label: Text('Facile')),
                    ButtonSegment(value: 'medium', label: Text('Moyen')),
                    ButtonSegment(value: 'hard', label: Text('Dur')),
                  ],
                  selected: {_difficulty},
                  onSelectionChanged: (values) {
                    setState(() => _difficulty = values.first);
                    widget.onDifficultyChanged(_difficulty);
                  },
                ),
                const SizedBox(height: 14),
                if (room.session?.status == 'in_progress')
                  FilledButton.icon(
                    onPressed: () => _play(room.session!.id),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Continuer la partie'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _start(room.id),
                    icon: const Icon(Icons.play_circle_rounded),
                    label: const Text('Lancer une partie'),
                  ),
                const SizedBox(height: 16),
                Text('Participants',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.w800)),
                for (final student in room.participants)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircularProfileAvatar(
                      imageUrl: student.profilePictureUrl,
                      initials: student.firstName.isEmpty
                          ? null
                          : student.firstName[0].toUpperCase(),
                      size: 40,
                    ),
                    title: Text(student.displayName),
                    subtitle: Text(student.email),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _start(String roomId) async {
    try {
      final games = await _dataSource.getMultiplayerGames();
      if (games.isEmpty) throw Exception('Aucun jeu disponible.');
      final started = await _dataSource.startMultiplayerSession(
        roomId: roomId,
        gameSlug: games.first.slug,
        difficulty: _difficulty,
      );
      await _play(started.session.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _play(String sessionId) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _SessionPlayerScreen(sessionId: sessionId),
    ));
    if (mounted) _reload();
  }
}

class _SessionPlayerScreen extends StatefulWidget {
  const _SessionPlayerScreen({required this.sessionId});

  final String sessionId;

  @override
  State<_SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<_SessionPlayerScreen> {
  late Future<MultiplayerSessionState> _future;
  int? _selected;
  DateTime _shownAt = DateTime.now();

  StudentRemoteDataSource get _dataSource => sl<StudentRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _future = _dataSource.getMultiplayerSession(widget.sessionId);
  }

  void _reload() {
    setState(() {
      _selected = null;
      _shownAt = DateTime.now();
      _future = _dataSource.getMultiplayerSession(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partie multijoueur')),
      body: FutureBuilder<MultiplayerSessionState>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingBlock();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
                child: _RetryBlock(
                    title: 'Partie indisponible', onRetry: _reload));
          }
          final state = snapshot.data!;
          if (state.session.status == 'finished' ||
              state.currentQuestion == null) {
            return _ResultsPanel(sessionId: widget.sessionId);
          }
          final question = state.currentQuestion!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              Text('Question ${question.round}/${question.totalRounds}',
                  style: AppTextStyles.labelMedium),
              const SizedBox(height: 10),
              Text(question.question,
                  style: AppTextStyles.titleLarge
                      .copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++) ...[
                ListTile(
                  selected: _selected == i,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selected == i
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  leading: Icon(
                    _selected == i
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _selected == i ? AppColors.primary : null,
                  ),
                  title: Text(question.options[i]),
                  onTap: () => setState(() => _selected = i),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _selected == null ? null : () => _answer(question),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Valider'),
              ),
              const SizedBox(height: 18),
              _LiveLeaderboard(entries: state.leaderboard),
            ],
          );
        },
      ),
    );
  }

  Future<void> _answer(MultiplayerQuestion question) async {
    final selected = _selected;
    if (selected == null) return;
    final elapsed = DateTime.now().difference(_shownAt).inMilliseconds;
    final result = await _dataSource.submitMultiplayerAnswer(
      sessionId: widget.sessionId,
      questionId: question.id,
      selectedIndex: selected,
      timeMs: elapsed,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            result.isCorrect ? '+${result.points} points' : 'Réponse corrigée'),
      ),
    );
    _reload();
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MultiplayerSessionResults>(
      future: sl<StudentRemoteDataSource>().getMultiplayerResults(sessionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingBlock();
        }
        final results = snapshot.data;
        if (snapshot.hasError || results == null) {
          return const _StateMessage(
            icon: Icons.timer_rounded,
            title: 'En attente',
            subtitle:
                'Le classement final sera disponible à la fin de la partie.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (results.myResult != null)
              _MultiplayerRankHero(entry: results.myResult!),
            const SizedBox(height: 18),
            _LiveLeaderboard(entries: results.leaderboard),
          ],
        );
      },
    );
  }
}

class _RequestData {
  const _RequestData({required this.classmates, required this.requests});

  final List<MultiplayerStudent> classmates;
  final List<MultiplayerRoomRequest> requests;
}

class _RankHero extends StatelessWidget {
  const _RankHero({required this.entry});

  final StudentLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircularProfileAvatar(
            imageUrl: entry.profilePictureUrl,
            initials: entry.firstName.isEmpty
                ? null
                : entry.firstName.substring(0, 1).toUpperCase(),
            size: 56,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            foregroundColor: Colors.white,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('#${entry.rank} • ${entry.totalXp} XP',
                style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 34),
        ],
      ),
    );
  }
}

class _MultiplayerRankHero extends StatelessWidget {
  const _MultiplayerRankHero({required this.entry});

  final MultiplayerLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Ton rang #${entry.rank} • ${entry.score} points',
          style: AppTextStyles.titleLarge
              .copyWith(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      );
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final StudentLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) => _TileShell(
        leading: '#${entry.rank}',
        title: '${entry.firstName} ${entry.lastName}',
        subtitle:
            '${entry.currentStreak} j de série • ${entry.completedSteps} étapes',
        trailing: '${entry.totalXp} XP',
        highlighted: entry.isCurrentUser,
      );
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room, required this.onTap});

  final MultiplayerRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: _TileShell(
          leading: room.status == 'in_progress' ? '▶' : '#',
          title: room.label ?? 'Salle ${room.roomCode}',
          subtitle:
              '${room.classLevel ?? 'Classe'} • ${room.participantCount} joueurs',
          trailing: room.roomCode,
          highlighted: room.status == 'in_progress',
        ),
      );
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final MultiplayerRoomRequest request;

  @override
  Widget build(BuildContext context) {
    final status = switch (request.status) {
      'approved' => 'Approuvée',
      'rejected' => 'Refusée',
      _ => 'En attente',
    };
    return _TileShell(
      leading: request.status == 'approved'
          ? '✓'
          : request.status == 'rejected'
              ? '!'
              : '…',
      title: status,
      subtitle: '${request.classLevel} • ${request.participants.length} élèves',
      trailing: request.createdRoomId == null ? '' : 'Salle prête',
      highlighted: request.status == 'approved',
    );
  }
}

class _LiveLeaderboard extends StatelessWidget {
  const _LiveLeaderboard({required this.entries});

  final List<MultiplayerLeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Classement de la partie',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final entry in entries) ...[
            _TileShell(
              leading: '#${entry.rank}',
              title: entry.displayName,
              subtitle: entry.finished ? 'Terminé' : 'En cours',
              trailing: '${entry.score}',
            ),
            const SizedBox(height: 8),
          ],
        ],
      );
}

class _TileShell extends StatelessWidget {
  const _TileShell({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.highlighted = false,
  });

  final String leading;
  final String title;
  final String subtitle;
  final String trailing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.12)
            : isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? AppColors.primary
              : isDark
                  ? AppColors.darkDivider
                  : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 38,
              child: Text(leading,
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w900))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(trailing,
              style: AppTextStyles.labelMedium
                  .copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _RetryBlock extends StatelessWidget {
  const _RetryBlock({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _StateMessage(
              icon: Icons.error_outline_rounded,
              title: title,
              subtitle: 'Réessaie dans un instant.'),
          FilledButton(onPressed: onRetry, child: const Text('Actualiser')),
        ],
      );
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(title,
                style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      );
}
