import 'package:flutter/material.dart';

/// 统一的应用主题配置，方便后续集中修改。
ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFB0B6FF),
    secondary: Color(0xFFFFCE6A),
    surface: Color(0xFF0E111A),
  );

  final baseTheme = ThemeData(colorScheme: scheme, useMaterial3: true);

  return baseTheme.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: baseTheme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
