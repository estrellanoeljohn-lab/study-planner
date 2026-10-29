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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
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
              leading: const Icon(Icons.blur_on_rounded, color: kMuted),
              title: const Text(
                'General study (no task)',
                style: TextStyle(color: kInk),
              ),
              onTap: () => Navigator.of(ctx).pop(const _Choice(null)),
            ),
            for (final t in open)
              ListTile(
                leading: const Icon(Icons.task_alt_rounded, color: kPrimary, size: 20),
                title: Text(t.title, style: const TextStyle(color: kInk)),
                subtitle: Text(
                  courseById[t.courseId]?.name ?? 'No course',
                  style: const TextStyle(color: kMuted),
                ),
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
    final accent = isFocus ? kPrimary : kSuccess;

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
          // Target chip
          Center(
            child: ActionChip(
              avatar: const Icon(Icons.menu_book_outlined, size: 18, color: kPrimary),
              label: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  _targetLabel(state, courseById, tasks),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kInk),
                ),
              ),
              onPressed:
                  state.running ? null : () => _pickTarget(tasks, courseById),
            ),
          ),
          const SizedBox(height: 32),

          // Timer ring
          Center(
            child: SizedBox(
              width: 270,
              height: 270,
              child: CustomPaint(
                painter: _RingPainter(
                  state.remaining / state.total,
                  accent,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _clock(state.remaining),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFocus
                            ? 'Session ${state.completed + 1} of $kSessionsPerCycle'
                            : 'Break time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 165,
                child: FilledButton(
                  onPressed: state.running ? controller.pause : controller.start,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                  ),
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
          const SizedBox(height: 28),

          // Today's summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDivider),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded,
                      color: kPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's focus",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDuration(todaySeconds)} · ${todaySessions.length} '
                      '${todaySessions.length == 1 ? 'session' : 'sessions'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                  ],
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

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2A3148)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Glow effect
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Progress arc
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
