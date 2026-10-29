import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

/// Reminder choices: minutes before the due time (null means no reminder).
const reminderOptions = <(int?, String)>[
  (null, 'None'),
  (0, 'At due time'),
  (60, '1 hour before'),
  (1440, '1 day before'),
];

String reminderLabel(int? minutes) {
  for (final (value, label) in reminderOptions) {
    if (value == minutes) return label;
  }
  return 'None';
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.courseId,
    required this.dueAt,
    required this.priority,
    required this.done,
    required this.notes,
    this.remindBefore,
  });

  final String id;
  final String title;
  final String courseId;
  final DateTime dueAt;
  final Priority priority;
  final bool done;
  final String notes;
  final int? remindBefore;

  DateTime? get remindAt => remindBefore == null
      ? null
      : dueAt.subtract(Duration(minutes: remindBefore!));

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final p = (data['priority'] as int?) ?? 1;
    return Task(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Untitled task',
      courseId: (data['courseId'] as String?) ?? '',
      dueAt: (data['dueAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: Priority.values[p < 0 ? 0 : (p > 2 ? 2 : p)],
      done: (data['done'] as bool?) ?? false,
      notes: (data['notes'] as String?) ?? '',
      remindBefore: data['remindBefore'] as int?,
    );
  }
}