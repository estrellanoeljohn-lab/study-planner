import 'package:cloud_firestore/cloud_firestore.dart';

import 'task.dart';

class TaskRepository {
  TaskRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('tasks');

  Stream<List<Task>> watchTasks() {
    return _col
        .orderBy('dueAt')
        .snapshots()
        .map((snap) => snap.docs.map(Task.fromDoc).toList());
  }

  Future<void> addTask({
    required String title,
    required String courseId,
    required DateTime dueAt,
    required Priority priority,
    String notes = '',
    int? remindBefore,
  }) {
    return _col.add({
      'title': title.trim(),
      'courseId': courseId,
      'dueAt': Timestamp.fromDate(dueAt),
      'priority': priority.index,
      'notes': notes.trim(),
      'remindBefore': remindBefore,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(
    String id, {
    required String title,
    required String courseId,
    required DateTime dueAt,
    required Priority priority,
    required String notes,
    required int? remindBefore,
  }) {
    return _col.doc(id).update({
      'title': title.trim(),
      'courseId': courseId,
      'dueAt': Timestamp.fromDate(dueAt),
      'priority': priority.index,
      'notes': notes.trim(),
      'remindBefore': remindBefore,
    });
  }

  Future<void> setDone(String id, bool done) {
    return _col.doc(id).update({
      'done': done,
      'completedAt': done ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> deleteTask(String id) => _col.doc(id).delete();
}