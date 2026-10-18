import 'package:flutter/material.dart';
import 'package:cashpaws/theme.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Live program variables and user metrics
  final int _pawCoinsBalance = 102;
  final double _usdEquivalent = 0.10;
  final int _currentDayStreak = 3; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                
                // ==========================================================
                // 1. LIVE COIN BALANCE TRACKER 
                // ==========================================================
                const Text(
                  "Your balance",
                  style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  "$_pawCoinsBalance",
                  style: const TextStyle(
                    color: CashPawsColors.neonBlue,
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: CashPawsColors.neonBlue,
                        blurRadius: 25,
                      ),
                    ],
                  ),
                ),
                Text(
                  "paw coins - \$${_usdEquivalent.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),

                                // ==========================================================
                // 2. DAILY LOGIN CALENDAR MODULE (Day 1 - Day 6 Rows)
                // ==========================================================
                buildDashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daily login",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Claim consecutive days to maximize your rewards margin.",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      
                      // Responsive horizontal list row layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          int dayNum = index + 1;
                          bool isClaimed = dayNum <= _currentDayStreak;
                          return Column(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isClaimed ? CashPawsColors.neonBlue.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isClaimed ? CashPawsColors.neonBlue : Colors.white10,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isClaimed ? Icons.check_circle_outline : Icons.lock_outline,
                                    size: 16,
                                    color: isClaimed ? CashPawsColors.neonBlue : Colors.white30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Day $dayNum",
                                style: TextStyle(
                                  color: isClaimed ? Colors.white : Colors.white30,
                                  fontSize: 11,
                                  fontWeight: isClaimed ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 20),
                      buildGlowingButton(
                        text: "Claim Today's Reward",
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // ==========================================================
                // 3. DAILY MISSIONS TRACKER WITH PROGRESS ARC
                // ==========================================================
                buildDashboardCard(
                  child: Column(
                    children: [
                      const Text(
                        "Daily missions", 
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      buildGlowingProgress(0.75), 
                      const SizedBox(height: 20),
                      _buildMissionStatusRow("Claim daily login", true),
                      _buildMissionStatusRow("Walk 2,000 steps (400/2000)", false),
                      _buildMissionStatusRow("Watch 3 Reward Ads (0/3)", false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // ==========================================================
                // 4. ACTION INTERACTION HUB
                // ==========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: buildGlowingButton(
                    text: "Start tracking",
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

    // ==========================================================
  // HELPER COMPONENT WIDGETS
  // ==========================================================

  Widget _buildMissionStatusRow(String missionText, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? CashPawsColors.neonGreen : Colors.white30,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              missionText,
              style: TextStyle(
                color: isDone ? Colors.white70 : Colors.white38,
                fontSize: 14,
                decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

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
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
