import 'package:flutter/material.dart';

class CashPawsColors {
  // Deep matte dark background shades
  static const Color backgroundMidnight = Color(0xFF0D0E11);
  static const Color cardSurface = Color(0xFF16181F);
  static const Color cardSurfaceLight = Color(0xFF20232E);

  // High-contrast vibrant accents
  static const Color neonGreenAccent = Color(0xFF00FF66);
  static const Color neonGreenDim = Color(0x3300FF66); // For subtle glowing overlays
  
  // Neutral text definitions
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8A8F9E);
  static const Color disabledGrey = Color(0xFF434651);
}

class CashPawsTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: CashPawsColors.backgroundMidnight,
      brightness: Brightness.dark,
      primaryColor: CashPawsColors.neonGreenAccent,
      cardColor: CashPawsColors.cardSurface,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: CashPawsColors.textPrimary, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(color: CashPawsColors.textSecondary, fontFamily: 'Roboto'),
      ),
    );
  }
}
