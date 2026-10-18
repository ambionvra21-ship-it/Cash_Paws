import 'package:flutter/material.dart';

class CashPawsColors {
  // Backgrounds
  static const Color backgroundMidnight = Color(0xFF070B19);
  static const Color cardBackground = Color(0xFF0F162A);
  
  // Accents & Glows
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color electricIndigo = Color(0xFF536DFE);
  static const Color neonGreen = Color(0xFF00E676);

  // Button Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonBlue, electricIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
