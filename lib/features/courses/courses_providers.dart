import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'course.dart';
import 'course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository?>((ref) {
  final uid = ref.watch(userProvider.select((u) => u.value?.uid));
  if (uid == null) return null;
  return CourseRepository(FirebaseFirestore.instance, uid);
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  if (repo == null) return Stream.value(const <Course>[]);
  return repo.watchCourses();
});