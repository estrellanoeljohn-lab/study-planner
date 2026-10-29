import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.courseId,
    required this.dueAt,
    required this.priority,
    required this.done,
  });

  final String id;
  final String title;
  final String courseId;
  final DateTime dueAt;
  final Priority priority;
  final bool done;

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
    );
  }
}