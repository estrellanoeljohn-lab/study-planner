import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/course_colors.dart';
import '../../core/dates.dart';
import '../../core/theme.dart';
import '../courses/course.dart';
import '../courses/courses_providers.dart';
import '../focus/focus_controller.dart';
import '../tasks/task.dart';
import '../tasks/tasks_providers.dart';
import 'stats_summary.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final courseById = {for (final c in courses) c.id: c};

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Could not load your stats.')),
        data: (sessions) {
          final now = DateTime.now();
          final summary = StatsSummary.compute(
            sessions: sessions,
            tasks: tasks,
            now: now,
          );
          final weekStart = startOfWeek(now);
          final weekLast = DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day + 6,
          );
          final rate = summary.completionRate;
          final maxDay =
              summary.daySeconds.fold<int>(0, (a, b) => a > b ? a : b);
          final scale = maxDay < 3600 ? 3600 : maxDay;
          final entries = summary.courseSeconds.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final maxCourse =
              (entries.isEmpty || entries.first.value == 0)
                  ? 1
                  : entries.first.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                'This week · ${formatShortDate(weekStart)} to '
                '${formatShortDate(weekLast)}',
                style: const TextStyle(fontSize: 14, color: kMuted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      formatDuration(summary.weekSeconds),
                      'Study time',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      '${summary.streak} ${summary.streak == 1 ? 'day' : 'days'}',
                      'Streak',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      rate == null ? '–' : '${(rate * 100).round()}%',
                      'Tasks done',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Study hours by day',
                child: SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: _DayBar(
                            label: weekdayShort(i + 1),
                            seconds: summary.daySeconds[i],
                            height: 100 * summary.daySeconds[i] / scale,
                            isToday: i == now.weekday - 1,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'By course',
                child: Column(
                  children: [
                    if (entries.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No focus sessions this week yet.',
                          style: TextStyle(color: kMuted),
                        ),
                      )
                    else
                      for (final e in entries)
                        _CourseRow(
                          courseId: e.key,
                          course: courseById[e.key],
                          seconds: e.value,
                          ratio: e.value / maxCourse,
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.seconds,
    required this.height,
    required this.isToday,
  });

  final String label;
  final int seconds;
  final double height;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final empty = seconds == 0;
    final barHeight = empty ? 4.0 : (height < 8 ? 8.0 : height);
    final color = empty
        ? const Color(0xFFDDE2EE)
        : (isToday ? kPrimary : const Color(0xFF6F8BEA));

    return Tooltip(
      message: '$label: ${formatDuration(seconds)}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: empty
                  ? BorderRadius.circular(2)
                  : const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? kInk : kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.courseId,
    required this.course,
    required this.seconds,
    required this.ratio,
  });

  final String? courseId;
  final Course? course;
  final int seconds;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final name =
        course?.name ?? (courseId == null ? 'General study' : 'Deleted course');
    final color = course == null
        ? kMuted
        : courseColors[course!.colorIndex % courseColors.length].accent;
    final factor = ratio < 0.02 ? 0.02 : (ratio > 1 ? 1.0 : ratio);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
              ),
              Text(
                formatDuration(seconds),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE3E7F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}