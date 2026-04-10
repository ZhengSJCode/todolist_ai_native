import 'package:flutter/material.dart';

import '../widgets/project_progress_card.dart';
import '../widgets/task_group_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      children: const [
        _HomeHeader(),
        SizedBox(height: 24),
        _HeroProgressCard(),
        SizedBox(height: 24),
        _SectionHeader(title: 'In Progress', count: '6'),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ProjectProgressCard(
                tag: 'Office Project',
                title: 'Grocery shopping app\ndesign',
                progress: 0.70,
                progressLabel: '70%',
                backgroundColor: Color(0xFFE7F3FF),
                accentColor: Color(0xFF0087FF),
              ),
              SizedBox(width: 16),
              ProjectProgressCard(
                tag: 'Personal Project',
                title: 'Uber Eats redesign\nchallange',
                progress: 0.52,
                progressLabel: '52%',
                backgroundColor: Color(0xFFFFE9E1),
                accentColor: Color(0xFFFF7D53),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        _SectionHeader(title: 'Task Groups', count: '4'),
        SizedBox(height: 16),
        TaskGroupTile(
          title: 'Office Project',
          subtitle: '23 Tasks',
          progressLabel: '70%',
          icon: Icons.work_outline_rounded,
          iconBackground: Color(0xFFFFE4F2),
          accentColor: Color(0xFFF96DB7),
        ),
        SizedBox(height: 16),
        TaskGroupTile(
          title: 'Personal Project',
          subtitle: '30 Tasks',
          progressLabel: '52%',
          icon: Icons.sell_outlined,
          iconBackground: Color(0xFFEDE4FF),
          accentColor: Color(0xFF8F63FF),
        ),
        SizedBox(height: 16),
        TaskGroupTile(
          title: 'Daily Study',
          subtitle: '30 Tasks',
          progressLabel: '87%',
          icon: Icons.menu_book_outlined,
          iconBackground: Color(0xFFFFE6D4),
          accentColor: Color(0xFFFF8A3D),
        ),
        SizedBox(height: 16),
        TaskGroupTile(
          title: 'Daily Study',
          subtitle: '3 Tasks',
          progressLabel: '87%',
          icon: Icons.wb_sunny_outlined,
          iconBackground: Color(0xFFFFF6D4),
          accentColor: Color(0xFFF0C400),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 23,
          backgroundColor: Color(0xFF1490D2),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Hello!', style: TextStyle(fontSize: 14)),
              SizedBox(height: 2),
              Text(
                'Livia Vaccaro',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Stack(
          children: const [
            Icon(Icons.notifications, color: Color(0xFF24252C)),
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                radius: 4,
                backgroundColor: Color(0xFF7D4CFF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3FF0), Color(0xFF5F33E1)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your today’s task\nalmost done!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5F33E1),
                  ),
                  child: const Text('View Task'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 7,
                  backgroundColor: Color(0x66FFFFFF),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '85%',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFEDE4FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count,
            style: const TextStyle(fontSize: 11, color: Color(0xFF5F33E1)),
          ),
        ),
      ],
    );
  }
}
