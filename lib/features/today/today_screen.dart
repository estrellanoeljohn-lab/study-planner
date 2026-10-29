import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dates.dart';
import '../../core/theme.dart';
import '../auth/auth_providers.dart';
import '../courses/course.dart';
import '../courses/courses_providers.dart';
import '../tasks/task.dart';
import '../tasks/task_tile.dart';
import '../tasks/tasks_providers.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final courseById = {for (final c in courses) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: const Text('Log out'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Could not load your tasks.')),
        data: (tasks) {
          final now = DateTime.now();
          final today = startOfDay(now);
          final tomorrow = today.add(const Duration(days: 1));
          final weekEnd = today.add(const Duration(days: 8));

          final dueToday =
              tasks.where((t) => isSameDay(t.dueAt, now)).toList();
          final overdue = tasks
              .where((t) => !t.done && t.dueAt.isBefore(today))
              .toList();
          final upcoming = tasks
              .where((t) =>
                  !t.done &&
                  !t.dueAt.isBefore(tomorrow) &&
                  t.dueAt.isBefore(weekEnd))
              .toList();
          final doneCount = dueToday.where((t) => t.done).length;

          Widget tile(Task t, {bool showDate = false}) => TaskTile(
                key: ValueKey(t.id),
                task: t,
                course: courseById[t.courseId],
                showDate: showDate,
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              Text(
                formatWeekdayDate(now),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kMuted,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dueToday.isEmpty
                          ? 'No tasks due today'
                          : '$doneCount of ${dueToday.length} tasks done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: dueToday.isEmpty
                          ? 0
                          : doneCount / dueToday.length,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              if (overdue.isNotEmpty) ...[
                const _SectionTitle('Overdue'),
                for (final t in overdue) tile(t, showDate: true),
              ],
              const _SectionTitle('Due today'),
              if (dueToday.isEmpty)
                const Text(
                  'Nothing due today. Tap + to add a task.',
                  style: TextStyle(color: kMuted),
                ),
              for (final t in dueToday) tile(t),
              const _SectionTitle('Coming up'),
              if (upcoming.isEmpty)
                const Text(
                  'Nothing due in the next 7 days.',
                  style: TextStyle(color: kMuted),
                ),
              for (final t in upcoming) tile(t, showDate: true),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: kInk,
        ),
      ),
    );
  }
}