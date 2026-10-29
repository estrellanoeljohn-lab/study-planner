import '../../core/dates.dart';
import '../focus/session_repository.dart';
import '../tasks/task.dart';

class StatsSummary {
  const StatsSummary({
    required this.weekSeconds,
    required this.daySeconds,
    required this.courseSeconds,
    required this.streak,
    required this.tasksDue,
    required this.tasksDone,
  });

  final int weekSeconds;

  /// Seconds studied per day, Monday first.
  final List<int> daySeconds;

  /// Seconds per course id this week (null means general study).
  final Map<String?, int> courseSeconds;

  final int streak;
  final int tasksDue;
  final int tasksDone;

  double? get completionRate => tasksDue == 0 ? null : tasksDone / tasksDue;

  factory StatsSummary.compute({
    required List<FocusSession> sessions,
    required List<Task> tasks,
    required DateTime now,
  }) {
    final weekStart = startOfWeek(now);
    final weekEnd =
        DateTime(weekStart.year, weekStart.month, weekStart.day + 7);

    final daySeconds = List<int>.filled(7, 0);
    final courseSeconds = <String?, int>{};
    final activeDays = <DateTime>{};
    var weekSeconds = 0;

    for (final s in sessions) {
      activeDays.add(startOfDay(s.endedAt));
      if (s.endedAt.isBefore(weekStart) || !s.endedAt.isBefore(weekEnd)) {
        continue;
      }
      weekSeconds += s.seconds;
      daySeconds[s.endedAt.weekday - 1] += s.seconds;
      courseSeconds[s.courseId] =
          (courseSeconds[s.courseId] ?? 0) + s.seconds;
    }

    // A streak counts back from today, or from yesterday if you have not
    // studied yet today.
    var streak = 0;
    var day = startOfDay(now);
    if (!activeDays.contains(day)) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    while (activeDays.contains(day)) {
      streak++;
      day = DateTime(day.year, day.month, day.day - 1);
    }

    final dueThisWeek = tasks
        .where((t) => !t.dueAt.isBefore(weekStart) && t.dueAt.isBefore(weekEnd))
        .toList();

    return StatsSummary(
      weekSeconds: weekSeconds,
      daySeconds: daySeconds,
      courseSeconds: courseSeconds,
      streak: streak,
      tasksDue: dueThisWeek.length,
      tasksDone: dueThisWeek.where((t) => t.done).length,
    );
  }
}