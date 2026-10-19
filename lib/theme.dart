import 'package:flutter/material.dart';

class CashPawsColors {
  // Clean white and soft grey backgrounds matching the photo design
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Vibrant high-conversion premium orange highlights
  static const Color rewardOrange = Color(0xFFFF7A30);
  static const Color rewardOrangeDim = Color(0x22FF7A30);
  static const Color buttonTextLight = Colors.white;
}

class CashPawsTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: CashPawsColors.backgroundLight,
      brightness: Brightness.light,
      primaryColor: CashPawsColors.rewardOrange,
      cardColor: CashPawsColors.cardSurface,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: CashPawsColors.textDark, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(color: CashPawsColors.textSecondary, fontFamily: 'Roboto'),
      ),
    );
  }
}
