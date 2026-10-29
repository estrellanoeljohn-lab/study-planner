import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'session_repository.dart';

enum FocusPhase { focus, rest }

// For quick testing, temporarily change kFocusSeconds to 60.
const kFocusSeconds = 25 * 60;
const kRestSeconds = 5 * 60;
const kSessionsPerCycle = 4;

class FocusState {
  const FocusState({
    this.phase = FocusPhase.focus,
    this.remaining = kFocusSeconds,
    this.running = false,
    this.completed = 0,
    this.courseId,
    this.taskId,
  });

  final FocusPhase phase;
  final int remaining;
  final bool running;
  final int completed;
  final String? courseId;
  final String? taskId;

  int get total => phase == FocusPhase.focus ? kFocusSeconds : kRestSeconds;

  FocusState copyWith({
    FocusPhase? phase,
    int? remaining,
    bool? running,
    int? completed,
  }) {
    return FocusState(
      phase: phase ?? this.phase,
      remaining: remaining ?? this.remaining,
      running: running ?? this.running,
      completed: completed ?? this.completed,
      courseId: courseId,
      taskId: taskId,
    );
  }
}

class FocusController extends Notifier<FocusState> {
  Timer? _timer;
  DateTime? _endsAt;

  @override
  FocusState build() {
    ref.onDispose(() => _timer?.cancel());
    return const FocusState();
  }

  void setTarget(String? courseId, String? taskId) {
    if (state.running) return;
    state = FocusState(
      phase: state.phase,
      remaining: state.remaining,
      running: state.running,
      completed: state.completed,
      courseId: courseId,
      taskId: taskId,
    );
  }

  void start() {
    if (state.running) return;
    _endsAt = DateTime.now().add(Duration(seconds: state.remaining));
    state = state.copyWith(running: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (!state.running) return;
    _timer?.cancel();
    state = state.copyWith(running: false, remaining: _secondsLeft());
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(running: false, remaining: state.total);
  }

  void skip() {
    _timer?.cancel();
    _advance(countSession: false);
  }

  // Uses the end time instead of counting ticks, so the timer stays
  // accurate even when the browser tab is in the background.
  int _secondsLeft() {
    final end = _endsAt;
    if (end == null) return state.remaining;
    final ms = end.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  void _tick() {
    final left = _secondsLeft();
    if (left <= 0) {
      _finish();
    } else if (left != state.remaining) {
      state = state.copyWith(remaining: left);
    }
  }

  void _finish() {
    _timer?.cancel();
    final wasFocus = state.phase == FocusPhase.focus;
    final courseId = state.courseId;
    final taskId = state.taskId;
    _advance(countSession: true);
    if (wasFocus) {
      ref
          .read(sessionRepositoryProvider)
          ?.addSession(
            courseId: courseId,
            taskId: taskId,
            seconds: kFocusSeconds,
          )
          .catchError((_) {});
    }
  }

  void _advance({required bool countSession}) {
    if (state.phase == FocusPhase.focus) {
      state = state.copyWith(
        phase: FocusPhase.rest,
        remaining: kRestSeconds,
        running: false,
        completed: countSession ? state.completed + 1 : state.completed,
      );
    } else {
      final cycleDone = state.completed >= kSessionsPerCycle;
      state = state.copyWith(
        phase: FocusPhase.focus,
        remaining: kFocusSeconds,
        running: false,
        completed: cycleDone ? 0 : state.completed,
      );
    }
  }
}

final sessionRepositoryProvider = Provider<SessionRepository?>((ref) {
  final uid = ref.watch(userProvider.select((u) => u.value?.uid));
  if (uid == null) return null;
  return SessionRepository(FirebaseFirestore.instance, uid);
});

final sessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  if (repo == null) return Stream.value(const <FocusSession>[]);
  return repo.watchSessions();
});

final focusControllerProvider =
    NotifierProvider<FocusController, FocusState>(FocusController.new);