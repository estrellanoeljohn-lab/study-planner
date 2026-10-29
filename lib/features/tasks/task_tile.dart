import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/course_colors.dart';
import '../../core/dates.dart';
import '../../core/theme.dart';
import '../courses/course.dart';
import 'task.dart';
import 'tasks_providers.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.course,
    this.showDate = false,
  });

  final Task task;
  final Course? course;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = course == null
        ? null
        : courseColors[course!.colorIndex % courseColors.length];
    final when = showDate
        ? '${formatWeekdayDate(task.dueAt)} · ${formatTime(task.dueAt)}'
        : formatTime(task.dueAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/task/${task.id}'),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: task.done
                    ? Colors.transparent
                    : (color?.accent.withValues(alpha: 0.2) ?? kDivider),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: task.done,
                  onChanged: (v) => ref
                      .read(taskRepositoryProvider)
                      ?.setDone(task.id, v ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: task.done
                              ? kMuted.withValues(alpha: 0.6)
                              : kInk,
                          decoration:
                              task.done ? TextDecoration.lineThrough : null,
                          decorationColor: kMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${course?.name ?? 'No course'} · $when',
                        style: TextStyle(
                          fontSize: 13,
                          color: kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.priority == Priority.high)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kError.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: kError.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'High',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kError,
                      ),
                    ),
                  ),
                if (color != null)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: color.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.accent.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
