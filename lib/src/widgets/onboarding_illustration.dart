import 'package:flutter/material.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 268,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFFECE4FF), const Color(0xFFF8F3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 54,
            child: Transform.rotate(
              angle: -0.22,
              child: _FloatingBadge(
                width: 68,
                color: const Color(0xFFFFE9E1),
                icon: Icons.auto_awesome_rounded,
                accent: const Color(0xFFFF7D53),
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: 42,
            child: Transform.rotate(
              angle: 0.18,
              child: _FloatingBadge(
                width: 76,
                color: const Color(0xFFE7F3FF),
                icon: Icons.calendar_today_rounded,
                accent: const Color(0xFF0087FF),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            child: Container(
              width: 208,
              height: 148,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: FittedBox(
                alignment: Alignment.topLeft,
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 172,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EBFF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 28,
                              color: Color(0xFF5F33E1),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Line(width: 70, color: Color(0xFF24252C)),
                                SizedBox(height: 8),
                                _Line(width: 102, color: Color(0xFFB9B4C9)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _ChecklistRow(accent: Color(0xFF5F33E1)),
                      const SizedBox(height: 6),
                      const _ChecklistRow(accent: Color(0xFFFF7D53)),
                      const SizedBox(height: 6),
                      const _ChecklistRow(accent: Color(0xFF0087FF)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.width,
    required this.color,
    required this.icon,
    required this.accent,
  });

  final double width;
  final Color color;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: accent.withAlpha(28),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.check_rounded, color: accent, size: 12),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: const [
              _Line(width: 64, color: Color(0xFF3B3848)),
              SizedBox(width: 8),
              _Line(width: 42, color: Color(0xFFB9B4C9)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
