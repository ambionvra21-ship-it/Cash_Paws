import 'package:flutter/material.dart';

const kBg = Color(0xFF05070D);
const kSurface = Color(0xFF0B1220);
const kLine = Color(0xFF12315C);
const kNeon = Color(0xFF14D1FF);
const kNeon2 = Color(0xFF2F6BFF);

final cashPawsTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBg,
  colorScheme: const ColorScheme.dark(primary: kNeon, secondary: kNeon2, surface: kSurface),
  navigationBarTheme: const NavigationBarThemeData(backgroundColor: kSurface, indicatorColor: kLine),
);
