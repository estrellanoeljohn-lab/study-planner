import 'package:flutter/material.dart';

class CourseColor {
  const CourseColor(this.name, this.accent, this.tint, this.onTint);

  final String name;
  final Color accent;
  final Color tint;
  final Color onTint;
}

const courseColors = [
  CourseColor('Amber',   Color(0xFFE8A838), Color(0xFF3D3018), Color(0xFFF5D590)),
  CourseColor('Sage',    Color(0xFF4CAF7D), Color(0xFF1A3328), Color(0xFF8FDDB5)),
  CourseColor('Coral',   Color(0xFFE87461), Color(0xFF3D1E18), Color(0xFFF5A899)),
  CourseColor('Sky',     Color(0xFF6C9BCF), Color(0xFF1A2A3D), Color(0xFFA8C8E8)),
  CourseColor('Orchid',  Color(0xFFB07CC6), Color(0xFF2D1A3D), Color(0xFFD4ADE4)),
  CourseColor('Peach',   Color(0xFFE8956C), Color(0xFF3D2518), Color(0xFFF5C4A0)),
  CourseColor('Mint',    Color(0xFF5CB8A5), Color(0xFF183D34), Color(0xFF98DBC9)),
];
