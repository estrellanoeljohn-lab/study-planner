import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/course_colors.dart';
import '../../core/dates.dart';
import '../../core/theme.dart';
import '../courses/course.dart';
import '../courses/courses_providers.dart';
import 'task.dart';
import 'tasks_providers.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key, this.taskId});

  /// When set, the screen edits this task instead of creating a new one.
  final String? taskId;

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  String? _courseId;
  DateTime _date = startOfDay(DateTime.now());
  TimeOfDay _time = const TimeOfDay(hour: 23, minute: 59);
  Priority _priority = Priority.medium;
    int? _remindBefore = 60;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.taskId;
    if (id == null) return;
    final tasks = ref.read(tasksProvider).value ?? const <Task>[];
    for (final t in tasks) {
      if (t.id == id) {
        _title.text = t.title;
        _notes.text = t.notes;
        _courseId = t.courseId;
        _date = startOfDay(t.dueAt);
        _time = TimeOfDay(hour: t.dueAt.hour, minute: t.dueAt.minute);
        _priority = t.priority;
                _priority = t.priority;
        _remindBefore = t.remindBefore;
        break;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final earliest = startOfDay(now).subtract(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(earliest) ? earliest : _date,
      firstDate: _date.isBefore(earliest) ? _date : earliest,
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_courseId == null) {
      setState(() => _error = 'Choose a course for this task.');
      return;
    }
    final repo = ref.read(taskRepositoryProvider);
    if (repo == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final dueAt = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
           if (_isEdit) {
        await repo.updateTask(
          widget.taskId!,
          title: _title.text,
          courseId: _courseId!,
          dueAt: dueAt,
          priority: _priority,
          notes: _notes.text,
          remindBefore: _remindBefore,
        );
      } else {
        await repo.addTask(
          title: _title.text,
          courseId: _courseId!,
          dueAt: dueAt,
          priority: _priority,
          notes: _notes.text,
          remindBefore: _remindBefore,
        );
      }
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Could not save the task. Check your connection and Firestore rules.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final dueAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit task' : 'New task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a task title'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Course',
                style: TextStyle(fontWeight: FontWeight.w700, color: kInk),
              ),
              const SizedBox(height: 10),
              if (courses.isEmpty) ...[
                const Text(
                  'You need a course before you can add a task.',
                  style: TextStyle(color: kMuted),
                ),
                TextButton(
                  onPressed: () => context.push('/add-course'),
                  child: const Text('Add a course'),
                ),
              ] else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in courses)
                      ChoiceChip(
                        label: Text(c.name),
                        selected: _courseId == c.id,
                        selectedColor:
                            courseColors[c.colorIndex % courseColors.length]
                                .tint,
                        onSelected: (_) => setState(() => _courseId = c.id),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due date',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(formatWeekdayDate(_date)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        child: Text(formatTime(dueAt)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.w700, color: kInk),
              ),
              const SizedBox(height: 10),
              SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment(value: Priority.low, label: Text('Low')),
                  ButtonSegment(value: Priority.medium, label: Text('Medium')),
                  ButtonSegment(value: Priority.high, label: Text('High')),
                ],
                selected: {_priority},
                onSelectionChanged: (s) =>
                    setState(() => _priority = s.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Colors.red.shade800)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Save changes' : 'Save task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}