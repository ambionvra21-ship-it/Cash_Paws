import 'package:flutter/material.dart';
import 'package:cashpaws/theme.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Daily Missions Card Container
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
                    buildGlowingProgress(0.75), 
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: buildGlowingButton(
                  text: "Start tracking",
                  onPressed: () {
                    // Handler logic
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Component: Glassmorphic Card Container
  Widget buildDashboardCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CashPawsColors.cardBackground,
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(
          color: CashPawsColors.neonBlue.withOpacity(0.15), 
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
      child: child;
    );
  }

  // Component: Glowing Action Capsule Button
  Widget buildGlowingButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: CashPawsColors.primaryGradient,
        borderRadius: BorderRadius.circular(28), 
        boxShadow: [
          BoxShadow(
            color: CashPawsColors.neonBlue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4), 
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

  // Component: Neon Circular Progress Wheel
  Widget buildGlowingProgress(double progressValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.05)),
          ),
        ),
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
              value: progressValue, 
              strokeWidth: 10,
              strokeCap: StrokeCap.round, 
              valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
            ),
          ),
        ),
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
