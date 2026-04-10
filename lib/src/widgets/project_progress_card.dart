import 'package:flutter/material.dart';

class ProjectProgressCard extends StatelessWidget {
  const ProjectProgressCard({
    super.key,
    required this.tag,
    required this.title,
    required this.progress,
    required this.progressLabel,
    required this.backgroundColor,
    required this.accentColor,
  });

  final String tag;
  final String title;
  final double progress;
  final String progressLabel;
  final Color backgroundColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 202,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6E6A7C)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressLabel,
            style: TextStyle(fontSize: 11, color: accentColor),
          ),
        ],
      ),
    );
  }
}
