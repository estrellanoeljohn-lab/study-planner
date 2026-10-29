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
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.tint,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.accent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
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
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: kMuted),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: kMuted.withValues(alpha: 0.5),
            size: 22,
          ),
        ],
      ),
    );
  }
}
