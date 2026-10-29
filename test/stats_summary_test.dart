import 'package:flutter_test/flutter_test.dart';
import 'package:studyplanner/features/focus/session_repository.dart';
import 'package:studyplanner/features/stats/stats_summary.dart';
import 'package:studyplanner/features/tasks/task.dart';

FocusSession session(DateTime at, {String? courseId, int seconds = 1500}) {
  return FocusSession(
    id: '$at',
    courseId: courseId,
    taskId: null,
    seconds: seconds,
    endedAt: at,
  );
}

Task task(DateTime due, {bool done = false}) {
  return Task(
    id: '$due',
    title: 'Task',
    courseId: 'a',
    dueAt: due,
    priority: Priority.medium,
    done: done,
    notes: '',
  );
}

void main() {
  // Thursday, Oct 29, 2026. The week runs Mon Oct 26 to Sun Nov 1.
  final now = DateTime(2026, 10, 29, 12);

  test('adds up study time for this week only', () {
    final summary = StatsSummary.compute(
      sessions: [
        session(DateTime(2026, 10, 26, 10), courseId: 'a'),
        session(DateTime(2026, 10, 29, 9), courseId: 'a'),
        session(DateTime(2026, 10, 29, 10)),
        session(DateTime(2026, 10, 25, 10), courseId: 'a'), // last week
      ],
      tasks: const [],
      now: now,
    );

    expect(summary.weekSeconds, 4500);
    expect(summary.daySeconds[0], 1500);
    expect(summary.daySeconds[3], 3000);
    expect(summary.courseSeconds['a'], 3000);
    expect(summary.courseSeconds[null], 1500);
  });

  test('counts a streak of consecutive days', () {
    final summary = StatsSummary.compute(
      sessions: [
        session(DateTime(2026, 10, 29, 9)),
        session(DateTime(2026, 10, 28, 9)),
        session(DateTime(2026, 10, 27, 9)),
        session(DateTime(2026, 10, 25, 9)),
      ],
      tasks: const [],
      now: now,
    );

    expect(summary.streak, 3);
  });

  test('keeps the streak alive if you have not studied yet today', () {
    final summary = StatsSummary.compute(
      sessions: [
        session(DateTime(2026, 10, 28, 9)),
        session(DateTime(2026, 10, 27, 9)),
      ],
      tasks: const [],
      now: now,
    );

    expect(summary.streak, 2);
  });

  test('calculates the task completion rate for this week', () {
    final summary = StatsSummary.compute(
      sessions: const [],
      tasks: [
        task(DateTime(2026, 10, 27, 12), done: true),
        task(DateTime(2026, 10, 30, 12), done: true),
        task(DateTime(2026, 10, 31, 12)),
        task(DateTime(2026, 11, 5, 12), done: true), // next week
      ],
      now: now,
    );

    expect(summary.tasksDue, 3);
    expect(summary.tasksDone, 2);
    expect(summary.completionRate, closeTo(2 / 3, 0.001));
  });
}