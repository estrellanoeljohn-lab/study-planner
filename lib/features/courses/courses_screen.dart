import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dates.dart';
import '../../core/theme.dart';
import '../tasks/task.dart';
import '../tasks/tasks_providers.dart';
import 'course.dart';
import 'course_tile.dart';
import 'courses_providers.dart';

String _subtitle(Course c, List<Task> tasks) {
  final open = tasks.where((t) => t.courseId == c.id && !t.done).length;
  final base =
      open == 0 ? 'No open tasks' : '$open open ${open == 1 ? 'task' : 'tasks'}';
  return c.examDate == null
      ? base
      : '$base · Exam ${formatShortDate(c.examDate!)}';
}

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: courses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Could not load your courses.')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No courses yet. Add your first one to get started.',
                  style: TextStyle(color: kMuted, fontSize: 15, height: 1.5),
                ),
              ),
            for (final c in list)
              CourseTile(
                name: c.name,
                colorIndex: c.colorIndex,
                subtitle: _subtitle(c, tasks),
              ),
            OutlinedButton.icon(
              onPressed: () => context.push('/add-course'),
              icon: const Icon(Icons.add),
              label: const Text('Add course'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}