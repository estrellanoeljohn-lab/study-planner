import 'package:flutter/material.dart';

import '../../core/course_colors.dart';
import '../../core/theme.dart';

class CourseTile extends StatelessWidget {
  const CourseTile({
    super.key,
    required this.name,
    required this.colorIndex,
    required this.subtitle,
  });

  final String name;
  final int colorIndex;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = courseColors[colorIndex % courseColors.length];
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color.onTint,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trimmed.isEmpty ? 'Course name' : trimmed,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}