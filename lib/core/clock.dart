import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the current time every 30 seconds so screens that depend on the
/// time (like reminders) refresh on their own.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});