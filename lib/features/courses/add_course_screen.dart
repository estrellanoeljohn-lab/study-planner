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
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: kInk),
                decoration: const InputDecoration(
                  labelText: 'Course name',
                  prefixIcon: Icon(Icons.menu_book_outlined, color: kMuted, size: 20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a course name'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'COLOR',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: kMuted,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: courseColors[i].accent,
                            shape: BoxShape.circle,
                            border: i == _colorIndex
                                ? Border.all(color: kInk, width: 3)
                                : Border.all(
                                    color: courseColors[i].accent.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                            boxShadow: i == _colorIndex
                                ? [
                                    BoxShadow(
                                      color: courseColors[i].accent.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: i == _colorIndex
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Exam date (optional)',
                    suffixIcon: _examDate == null
                        ? const Icon(Icons.calendar_today_outlined, color: kMuted)
                        : IconButton(
                            icon: const Icon(Icons.close, color: kMuted),
                            tooltip: 'Clear date',
                            onPressed: () => setState(() => _examDate = null),
                          ),
                  ),
                  child: Text(
                    _examDate == null ? 'Not set' : formatShortDate(_examDate!),
                    style: TextStyle(
                      color: _examDate == null ? kMuted : kInk,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kError.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: kError, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1A1200),
                        ),
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
