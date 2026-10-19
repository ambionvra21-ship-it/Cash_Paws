import 'package:flutter/material.dart';
import '../theme.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Simulated tracking parameters for visual rendering demonstration
  int currentCoins = 145; 
  int remainingSpins = 3;
  int userSteps = 4520;

  @override
  Widget build(BuildContext context) {
    bool isMaxed = currentCoins >= CashPawsConfig.maxDailyCoins;
    double dailyProgress = (currentCoins / CashPawsConfig.maxDailyCoins).clamp(0.0, 1.0);
    double walletUsdValue = currentCoins * CashPawsConfig.coinToUsdMultiplier;
    double cashoutProgress = (walletUsdValue / CashPawsConfig.targetWithdrawalThreshold).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: CashPawsColors.textPrimary),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: CashPawsColors.cardSurfaceLight,
              child: Icon(Icons.person, size: 18, color: CashPawsColors.neonGreenAccent),
            ),
          )
        ],
      ),

            body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. Grand Daily Earnings Summary Panel ---
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CashPawsColors.neonGreenDim, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'DAILY EARNINGS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: isMaxed ? CashPawsColors.neonGreenAccent : CashPawsColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$currentCoins / ${CashPawsConfig.maxDailyCoins} COINS',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.black,
                              color: CashPawsColors.textPrimary,
                            ),
                          ),
                          Text(
                            isMaxed ? 'DAILY GOAL REACHED [MAXED]' : 'EARN MORE TO HIT YOUR CEILING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isMaxed ? CashPawsColors.neonGreenAccent : CashPawsColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: dailyProgress,
                              minHeight: 10,
                              backgroundColor: CashPawsColors.cardSurfaceLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreenAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- 2. Live Wallet Value Conversion Indicator ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CURRENT BALANCE: \$${walletUsdValue.toStringAsFixed(2)} USD',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CashPawsColors.textPrimary),
                              ),
                              Text(
                                'Progress to \$${CashPawsConfig.targetWithdrawalThreshold.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 11, color: CashPawsColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: cashoutProgress,
                              minHeight: 4,
                              backgroundColor: CashPawsColors.cardSurface,
                              valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreenAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 3. Interactive Task Segment Control Blocks ---
                    _buildTaskCard(
                      title: 'TASK 1: DAILY LOGIN STREAK',
                      subtitle: 'Day 5 Bonus (+${CashPawsConfig.coinsDailyLogin} Coins)',
                      badgeText: 'Triggers Ad',
                      buttonText: 'CLAIM +${CashPawsConfig.coinsDailyLogin} COINS',
                      isDisabled: isMaxed,
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),

                    _buildTaskCard(
                      title: 'TASK 2: WALKING STEPS',
                      subtitle: '$userSteps / 5,000 Steps Today',
                      badgeText: 'Rewarded Video Ad',
                      buttonText: 'CLAIM ${CashPawsConfig.coinsWalkingSteps} COINS (WATCH 2x VIDEO)',
                      isDisabled: isMaxed,
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),

                    _buildTaskCard(
                      title: 'TASK 3: LUCKY SPIN WHEEL',
                      subtitle: 'Spins Left: $remainingSpins / 5',
                      badgeText: 'Ticket Needed',
                      buttonText: 'SPIN NOW! (REQUIRES TICKET)',
                      isDisabled: isMaxed || remainingSpins <= 0,
                      onTap: () {},
                      secondaryButton: _buildSecondaryButton(
                        text: 'WATCH VIDEO FOR TICKET (+5 COINS)',
                        onTap: isMaxed ? null : () {},
                      ),
                    ),
                    const SizedBox(height: 20),
                    // --- 4. High-Yield Offerwall Alternative Pathway ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.amber, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'INSTANT CASH SHORTCUT',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Want to skip the daily calculation limit?',
                            style: TextStyle(fontSize: 11, color: CashPawsColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                            onPressed: () {},
                            child: const Text('⚡ OPEN PREMIUM OFFERWALL', style: TextStyle(fontWeight: FontWeight.black, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 5. Dedicated Anchored Base Footprint for AdMob ---
            Container(
              width: double.infinity,
              height: 54,
              color: CashPawsColors.cardSurface,
              alignment: Alignment.center,
              child: const Text(
                'ANCHORED ADMOB BANNER AD HERE',
                style: TextStyle(color: CashPawsColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required String buttonText,
    required bool isDisabled,
    required VoidCallback onTap,
    Widget? secondaryButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CashPawsColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CashPawsColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badgeText, style: const TextStyle(fontSize: 9, color: CashPawsColors.neonGreenAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CashPawsColors.textPrimary)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? CashPawsColors.disabledGrey : CashPawsColors.neonGreenAccent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: CashPawsColors.disabledGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: isDisabled ? null : onTap,
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          if (secondaryButton != null) ...[
            const SizedBox(height: 8),
            secondaryButton,
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({required String text, required VoidCallback? onTap}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: onTap == null ? CashPawsColors.disabledGrey : CashPawsColors.neonGreenAccent.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: onTap == null ? CashPawsColors.disabledGrey : CashPawsColors.neonGreenAccent,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
