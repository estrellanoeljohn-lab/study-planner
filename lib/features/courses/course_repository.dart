import 'package:cloud_firestore/cloud_firestore.dart';

import 'course.dart';

class CourseRepository {
  CourseRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('courses');

  Stream<List<Course>> watchCourses() {
    return _col
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(Course.fromDoc).toList());
  }

  Future<void> addCourse({
    required String name,
    required int colorIndex,
    DateTime? examDate,
  }) {
    return _col.add({
      'name': name.trim(),
      'colorIndex': colorIndex,
      'examDate': examDate == null ? null : Timestamp.fromDate(examDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}