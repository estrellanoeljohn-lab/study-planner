import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.colorIndex,
    this.examDate,
  });

  final String id;
  final String name;
  final int colorIndex;
  final DateTime? examDate;

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Course(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Untitled',
      colorIndex: (data['colorIndex'] as int?) ?? 0,
      examDate: (data['examDate'] as Timestamp?)?.toDate(),
    );
  }
}