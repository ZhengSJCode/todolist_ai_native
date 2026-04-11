import 'package:flutter/material.dart';

class TaskDetailCard extends StatelessWidget {
  const TaskDetailCard({
    super.key,
    required this.category,
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconBackground,
    required this.statusBackground,
    required this.statusColor,
    this.onTap,
  });

  final String category;
  final String title;
  final String time;
  final String status;
  final IconData icon;
  final Color iconBackground;
  final Color statusBackground;
  final Color statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6E6A7C),
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 14, color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  size: 14,
                  color: Color(0xFFAB94FF),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAB94FF),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 9, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
