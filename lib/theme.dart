import 'package:flutter/material.dart';

// Change these hex codes to restyle the whole app (keep the 0xFF at the start).
const kBg = Color(0xFF05070D);       // main background
const kSurface = Color(0xFF0B1220);  // cards and bars
const kLine = Color(0xFF12315C);     // card borders
const kNeon = Color(0xFF14D1FF);     // main glow colour
const kNeon2 = Color(0xFF2F6BFF);    // second colour of the gradient

final cashPawsTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBg,
  colorScheme: const ColorScheme.dark(primary: kNeon, secondary: kNeon2, surface: kSurface),
  appBarTheme: const AppBarTheme(backgroundColor: kSurface),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: kSurface,
    indicatorColor: kNeon.withOpacity(.18),
    labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kNeon,
      foregroundColor: const Color(0xFF001018),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kLine)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kLine)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kNeon)),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: kSurface,
    contentTextStyle: const TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: kLine)),
  ),
);
