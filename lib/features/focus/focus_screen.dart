import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/theme.dart';
import '../courses/course.dart';
import '../courses/courses_providers.dart';
import '../tasks/task.dart';
import '../tasks/tasks_providers.dart';
import 'focus_controller.dart';
import 'session_repository.dart';

class _Choice {
  const _Choice(this.task);
  final Task? task;
}

String _clock(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key, this.taskId});

  /// Set when the screen is opened from a task's "Start focus session".
  final String? taskId;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyLink());
  }

  @override
  void didUpdateWidget(FocusScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskId != oldWidget.taskId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyLink());
    }
  }

  void _applyLink() {
    final id = widget.taskId;
    if (id == null || !mounted) return;
    final tasks = ref.read(tasksProvider).value ?? const <Task>[];
    final task = tasks.where((t) => t.id == id).firstOrNull;
    if (task == null) return;
    ref
        .read(focusControllerProvider.notifier)
        .setTarget(task.courseId, task.id);
  }

  Future<void> _pickTarget(
    List<Task> tasks,
    Map<String, Course> courseById,
  ) async {
    final open = tasks.where((t) => !t.done).toList();
    final choice = await showModalBottomSheet<_Choice>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'What are you studying?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
            ),
            ListTile(
              title: const Text('General study (no task)'),
              onTap: () => Navigator.of(ctx).pop(const _Choice(null)),
            ),
            for (final t in open)
              ListTile(
                title: Text(t.title),
                subtitle: Text(courseById[t.courseId]?.name ?? 'No course'),
                onTap: () => Navigator.of(ctx).pop(_Choice(t)),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    ref
        .read(focusControllerProvider.notifier)
        .setTarget(choice.task?.courseId, choice.task?.id);
  }

  String _targetLabel(
    FocusState s,
    Map<String, Course> courseById,
    List<Task> tasks,
  ) {
    final task = tasks.where((t) => t.id == s.taskId).firstOrNull;
    final course = courseById[s.courseId];
    if (task != null) return '${course?.name ?? 'No course'} · ${task.title}';
    if (course != null) return course.name;
    return 'Choose what you are studying';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusControllerProvider);
    final controller = ref.read(focusControllerProvider.notifier);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final sessions =
        ref.watch(sessionsProvider).value ?? const <FocusSession>[];
    final courseById = {for (final c in courses) c.id: c};

    final isFocus = state.phase == FocusPhase.focus;
    final accent = isFocus ? kPrimary : const Color(0xFF0CA678);

    final now = DateTime.now();
    final todaySessions =
        sessions.where((s) => isSameDay(s.endedAt, now)).toList();
    final todaySeconds =
        todaySessions.fold<int>(0, (sum, s) => sum + s.seconds);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: ActionChip(
              avatar: const Icon(Icons.menu_book_outlined, size: 18),
              label: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  _targetLabel(state, courseById, tasks),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onPressed:
                  state.running ? null : () => _pickTarget(tasks, courseById),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _RingPainter(state.remaining / state.total, accent),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _clock(state.remaining),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                      ),
                      Text(
                        isFocus
                            ? 'Session ${state.completed + 1} of $kSessionsPerCycle'
                            : 'Break time',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: FilledButton(
                  onPressed: state.running ? controller.pause : controller.start,
                  child: Text(
                    state.running
                        ? 'Pause'
                        : (state.remaining < state.total ? 'Resume' : 'Start'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: OutlinedButton(
                  onPressed: controller.reset,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: controller.skip,
              child: Text(isFocus ? 'Skip to break' : 'Skip break'),
            ),
          ),
          Center(
            child: Text(
              isFocus
                  ? 'Next: ${kRestSeconds ~/ 60} min break'
                  : 'Next: ${kFocusSeconds ~/ 60} min focus',
              style: const TextStyle(fontSize: 13, color: kMuted),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today’s focus',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDuration(todaySeconds)} · ${todaySessions.length} '
                  '${todaySessions.length == 1 ? 'session' : 'sessions'}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFDDE2EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}