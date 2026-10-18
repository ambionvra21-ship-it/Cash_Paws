import 'package:flutter/material.dart';
import 'package:cashpaws/theme.dart';
import 'package:cashpaws/screens/home_screen.dart';
import 'package:cashpaws/screens/walk_screen.dart';
import 'package:cashpaws/screens/wallet_screen.dart';

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

Widget buildGlowingProgress(double progressValue) {
  return Stack(
    alignment: Alignment.center,
    children: [
      // Track Background
      SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          value: 1.0,
          strokeWidth: 10,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.05)),
        ),
      ),
      // Glowing Neon Progress Arc
      SizedBox(
        width: 100,
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CashPawsColors.neonGreen.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            value: progressValue, // e.g., 0.75 for 3/4
            strokeWidth: 10,
            strokeCap: StrokeCap.round, // Smooth rounded edges on the arc bar
            valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
          ),
        ),
      ),
      // Center Text
      Text(
        "${(progressValue * 4).toInt()}/4",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

// Replace 'your_project_name' with your actual Flutter project package name
import 'package:your_project_name/theme.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // ==========================================
  // 5. MAIN APPLICATION SCAFFOLD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight, // Uniform dark canvas
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Your newly built premium card container
              buildDashboardCard(
                child: Column(
                  children: [
                    const Text(
                      "Daily missions", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Your neon custom progress wheel
                    buildGlowingProgress(0.75), 
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // Your glowing action capsule button
                child: buildGlowingButton(
                  text: "Start tracking",
                  onPressed: () {
                    // Action handler when pressed
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. GLASSMORPHIC CARD CONTAINER COMPONENT
  // ==========================================
  Widget buildDashboardCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CashPawsColors.cardBackground,
        borderRadius: BorderRadius.circular(24), // Smoother, rounder modern corners
        border: Border.all(
          color: CashPawsColors.neonBlue.withOpacity(0.15), // Subtle neon outline
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================
  // 3. GLOWING GRADIENT BUTTON COMPONENT
  // ==========================================
  Widget buildGlowingButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: CashPawsColors.primaryGradient,
        borderRadius: BorderRadius.circular(28), // Fully rounded capsule look
        boxShadow: [
          BoxShadow(
            color: CashPawsColors.neonBlue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4), // Generates a soft neon under-glow
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 4. NEON CIRCULAR PROGRESS INDICATOR COMPONENT
  // ==========================================
  Widget buildGlowingProgress(double progressValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Track Background
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.05)),
          ),
        ),
        // Glowing Neon Progress Arc
        SizedBox(
          width: 100,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CashPawsColors.neonGreen.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              value: progressValue, // e.g., 0.75 for 3/4
              strokeWidth: 10,
              strokeCap: StrokeCap.round, // Smooth rounded edges on the arc bar
              valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
            ),
          ),
        ),
        // Center Text
        Text(
          "${(progressValue * 4).toInt()}/4",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

    ],
  );
}
