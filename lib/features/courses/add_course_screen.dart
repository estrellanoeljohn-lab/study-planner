import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/course_colors.dart';
import '../../core/dates.dart';
import '../../core/theme.dart';
import 'course_tile.dart';
import 'courses_providers.dart';

class AddCourseScreen extends ConsumerStatefulWidget {
  const AddCourseScreen({super.key});

  @override
  ConsumerState<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends ConsumerState<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  int _colorIndex = 0;
  DateTime? _examDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(courseRepositoryProvider);
    if (repo == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await repo.addCourse(
        name: _name.text,
        colorIndex: _colorIndex,
        examDate: _examDate,
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Could not save the course. Check your connection and Firestore rules.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New course')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _name,
                builder: (context, value, _) => CourseTile(
                  name: value.text,
                  colorIndex: _colorIndex,
                  subtitle: 'Preview · 0 open tasks',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Course name'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a course name'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Color',
                style: TextStyle(fontWeight: FontWeight.w700, color: kInk),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: [
                  for (var i = 0; i < courseColors.length; i++)
                    Semantics(
                      label: courseColors[i].name,
                      button: true,
                      selected: i == _colorIndex,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _colorIndex = i),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: courseColors[i].accent,
                            shape: BoxShape.circle,
                            border: i == _colorIndex
                                ? Border.all(color: kInk, width: 3)
                                : null,
                          ),
                          child: i == _colorIndex
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Exam date (optional)',
                    suffixIcon: _examDate == null
                        ? const Icon(Icons.calendar_today_outlined)
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear date',
                            onPressed: () => setState(() => _examDate = null),
                          ),
                  ),
                  child: Text(
                    _examDate == null ? 'Not set' : formatShortDate(_examDate!),
                  ),
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
                    : const Text('Save course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
