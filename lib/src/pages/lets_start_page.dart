import 'package:flutter/material.dart';

import '../widgets/onboarding_illustration.dart';

/// Onboarding / entry screen — Figma node 101:100.
class LetsStartPage extends StatelessWidget {
  const LetsStartPage({super.key, this.onStart});

  /// Called when the user taps "Get Started".
  /// If null the button is still rendered but does nothing (for test isolation).
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const OnboardingIllustration(),
              const SizedBox(height: 40),
              const Text(
                "Let's Start!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF24252C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage your daily task and\nstay on top of everything',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E6A7C),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5F33E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
