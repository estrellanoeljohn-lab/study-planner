import 'package:cloud_firestore/cloud_firestore.dart';

class FocusSession {
  const FocusSession({
    required this.id,
    required this.courseId,
    required this.taskId,
    required this.seconds,
    required this.endedAt,
  });

  final String id;
  final String? courseId;
  final String? taskId;
  final int seconds;
  final DateTime endedAt;

  factory FocusSession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FocusSession(
      id: doc.id,
      courseId: data['courseId'] as String?,
      taskId: data['taskId'] as String?,
      seconds: (data['seconds'] as int?) ?? 0,
      endedAt: (data['endedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SessionRepository {
  SessionRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('sessions');

  /// Latest 200 sessions only, which keeps Firestore reads low.
  Stream<List<FocusSession>> watchSessions() {
    return _col
        .orderBy('endedAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs.map(FocusSession.fromDoc).toList());
  }

  Future<void> addSession({
    String? courseId,
    String? taskId,
    required int seconds,
  }) {
    return _col.add({
      'courseId': courseId,
      'taskId': taskId,
      'seconds': seconds,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
}