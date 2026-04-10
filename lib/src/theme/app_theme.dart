import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF5F33E1);
  const textPrimary = Color(0xFF24252C);

  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: Colors.white,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
  );
}
