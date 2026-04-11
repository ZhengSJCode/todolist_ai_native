import 'package:flutter/material.dart';

class TaskGroupTile extends StatelessWidget {
  const TaskGroupTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.icon,
    required this.iconBackground,
    required this.accentColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final IconData icon;
  final Color iconBackground;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 32,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6E6A7C),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(progressLabel, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
