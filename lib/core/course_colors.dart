import 'package:flutter/material.dart';

class CourseColor {
  const CourseColor(this.name, this.accent, this.tint, this.onTint);

  final String name;
  final Color accent;
  final Color tint;
  final Color onTint;
}

const courseColors = [
  CourseColor('Blue', Color(0xFF3B5BDB), Color(0xFFDBE4FF), Color(0xFF2B46A8)),
  CourseColor('Teal', Color(0xFF0CA678), Color(0xFFD3F5E8), Color(0xFF05674D)),
  CourseColor('Orange', Color(0xFFF76707), Color(0xFFFFE6D2), Color(0xFF9A3F06)),
  CourseColor('Violet', Color(0xFF9C36B5), Color(0xFFF1DDF7), Color(0xFF6A1B82)),
  CourseColor('Rose', Color(0xFFD6336C), Color(0xFFFFE0EB), Color(0xFF9C1F4B)),
];