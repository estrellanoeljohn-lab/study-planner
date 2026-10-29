import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/course_colors.dart';
import '../../core/dates.dart';
import '../../core/theme.dart';
import '../courses/course.dart';
import '../courses/courses_providers.dart';
import 'task.dart';
import 'tasks_providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(taskRepositoryProvider)?.deleteTask(task.id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final task = (tasksAsync.value ?? const <Task>[])
        .where((t) => t.id == taskId)
        .firstOrNull;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: tasksAsync.isLoading
              ? const CircularProgressIndicator()
              : const Text('This task no longer exists.'),
        ),
      );
    }

    final course = courses.where((c) => c.id == task.courseId).firstOrNull;
    final courseColor = course == null
        ? null
        : courseColors[course.colorIndex % courseColors.length];
    final overdue = !task.done && task.dueAt.isBefore(DateTime.now());
    final (priorityText, priorityBg, priorityFg) = switch (task.priority) {
      Priority.low => ('Low priority', const Color(0xFFE3E7F0), kMuted),
      Priority.medium => (
          'Medium priority',
          const Color(0xFFFFE8CC),
          const Color(0xFF8F4A00),
        ),
      Priority.high => (
          'High priority',
          const Color(0xFFFFE0E0),
          const Color(0xFFA61E1E),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit task',
            onPressed: () => context.push('/task/${task.id}/edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  course?.name ?? 'No course',
                  courseColor?.tint ?? const Color(0xFFE3E7F0),
                  courseColor?.onTint ?? kMuted,
                ),
                _InfoChip(priorityText, priorityBg, priorityFg),
                _InfoChip(
                  '${formatWeekdayDate(task.dueAt)} · ${formatTime(task.dueAt)}',
                  overdue ? const Color(0xFFFFE0E0) : const Color(0xFFE8EDFF),
                  overdue ? const Color(0xFFA61E1E) : const Color(0xFF2F4BC4),
                ),
                if (task.remindBefore != null)
                  _InfoChip(
                    'Reminder: ${reminderLabel(task.remindBefore)}',
                    const Color(0xFFE8EDFF),
                    const Color(0xFF2F4BC4),
                  ),
                if (task.done)
                  const _InfoChip(
                    'Done',
                    Color(0xFFD3F5E8),
                    Color(0xFF05674D),
                  ),
              ],
            ),
            const SizedBox(height: 20),
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
                    'Notes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.notes.isEmpty ? 'No notes yet.' : task.notes,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: task.notes.isEmpty ? kMuted : kInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.go('/focus?taskId=${task.id}'),
              icon: const Icon(Icons.timer_outlined),
              label: const Text('Start focus session'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => ref
                  .read(taskRepositoryProvider)
                  ?.setDone(task.id, !task.done),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(task.done ? 'Mark as not done' : 'Mark as done'),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => _confirmDelete(context, ref, task),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC92A2A),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Delete task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text, this.background, this.foreground);

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}