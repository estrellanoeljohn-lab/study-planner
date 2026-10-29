import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'task.dart';
import 'task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository?>((ref) {
  final uid = ref.watch(userProvider.select((u) => u.value?.uid));
  if (uid == null) return null;
  return TaskRepository(FirebaseFirestore.instance, uid);
});

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  if (repo == null) return Stream.value(const <Task>[]);
  return repo.watchTasks();
});