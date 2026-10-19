import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math' as math;
import '../theme.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Core Operational Earning Trackers
  int currentCoins = 0; 
  int remainingSpins = 5;
  int userSteps = 4520;
  bool isDailyLimitMaxed = false;

  // Wheel Animation Elements
  late AnimationController _wheelController;
  double _wheelRotationAngle = 0.0;

  // AdMob Network SDK Reference Drivers
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  @override
  void initState() {
    super.initState();
    _initAdMobSDK();
    
    // Set up a simple 3-second code-based rotating animation spinner
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          _wheelRotationAngle = _wheelController.value * 2 * math.pi * 5; 
        });
      });
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  Future<void> _initAdMobSDK() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    if (_isInterstitialLoading || isDailyLimitMaxed) return;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: CashPawsConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _loadInterstitialAd();
        },
      ),
    );
  }

  void _loadRewardedAd() {
    if (_isRewardedLoading || isDailyLimitMaxed) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: CashPawsConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          _loadRewardedAd();
        },
      ),
    );
  }

    void _processSecureReward(int amount) {
    if (isDailyLimitMaxed) return;
    setState(() {
      if (currentCoins + amount >= CashPawsConfig.maxDailyCoins) {
        currentCoins = CashPawsConfig.maxDailyCoins;
        isDailyLimitMaxed = true;
        _showLimitReachedAlert();
      } else {
        currentCoins += amount;
      }
    });
  }

  void _showLimitReachedAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily coin limit reached! Come back tomorrow to keep earning.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _handleDailyLogin() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose(); _interstitialAd = null; _loadInterstitialAd();
          _processSecureReward(CashPawsConfig.coinsDailyLogin);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose(); _interstitialAd = null; _loadInterstitialAd();
          _processSecureReward(CashPawsConfig.coinsDailyLogin);
        },
      );
      _interstitialAd!.show();
    } else {
      _loadInterstitialAd();
      _processSecureReward(CashPawsConfig.coinsDailyLogin); 
    }
  }

  void _openWalkingStepsWindow() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CashPawsColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: CashPawsColors.rewardOrange, size: 28),
                  SizedBox(width: 8),
                  Text('Steps Activity Monitoring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CashPawsColors.textDark)),
                ],
              ),
              const SizedBox(height: 20),
              // Monitoring Graph Panel Widget Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMiniGraphBar("2 Days Ago", 0.4, "2,000"),
                  _buildMiniGraphBar("Yesterday", 0.7, "3,500"),
                  _buildMiniGraphBar("Today", 0.9, "4,520", isHighlight: true),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CashPawsColors.rewardOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); 
                  _handleWatchVideoReward(isSpinReward: false);
                },
                child: const Text('WATCH VIDEO AD TO CLAIM COINS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSpinWheelWindow() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: CashPawsColors.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Lucky Spin Wheel ($remainingSpins/5 Left)', style: const TextStyle(color: CashPawsColors.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Native Canvas Animated Custom Painter Wheel Spinner
                  Transform.rotate(
                    angle: _wheelRotationAngle,
                    child: CustomPaint(
                      size: const Size(160, 160),
                      painter: BasicWheelPainter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.arrow_drop_up, color: CashPawsColors.rewardOrange, size: 32),
                  const Text('Every spin safely launches a sponsor video ad!', style: TextStyle(fontSize: 12, color: CashPawsColors.textSecondary), textAlign: TextAlign.center),
                ],
              ),
              actionsAlignment: MainAxisAlignment.stretch,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CashPawsColors.rewardOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: remainingSpins <= 0 || _wheelController.isAnimating || isDailyLimitMaxed ? null : () {
                    // Trigger the animation rotation sequence first
                    _wheelController.forward(from: 0.0).then((_) {
                      setDialogState(() { remainingSpins--; });
                      Navigator.pop(context); 
                      _handleWatchVideoReward(isSpinReward: true); // Force ad display loop immediately on spin stop
                    });
                  },
                  child: const Text('LAUNCH SPIN GAME', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleWatchVideoReward({required bool isSpinReward}) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) { ad.dispose(); _rewardedAd = null; _loadRewardedAd(); },
        onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); _rewardedAd = null; _loadRewardedAd(); },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) => _processSecureReward(
          isSpinReward ? CashPawsConfig.coinsPerLuckySpin : CashPawsConfig.coinsWalkingSteps
        ),
      );
    } else {
      _loadRewardedAd();
      _processSecureReward(isSpinReward ? CashPawsConfig.coinsPerLuckySpin : CashPawsConfig.coinsWalkingSteps); 
    }
  }

  void _openProfileSettingsWindow() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CashPawsColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('User Account Hub', style: TextStyle(color: CashPawsColors.textDark, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(leading: Icon(Icons.account_circle, size: 40), title: Text('Verified User'), subtitle: Text('id: status_active_01')),
              const Divider(),
              ListTile(title: const Text('PayPal ID Payout Route'), subtitle: const Text('Not Configured'), trailing: TextButton(onPressed: (){}, child: const Text('Edit'))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniGraphBar(String label, double fillPct, String stepCount, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(stepCount, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isHighlight ? CashPawsColors.rewardOrange : CashPawsColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          height: 100,
          width: 24,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 100 * fillPct,
            decoration: BoxDecoration(color: isHighlight ? CashPawsColors.rewardOrange : Colors.grey.shade400, borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: CashPawsColors.textSecondary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double dailyProgress = (currentCoins / CashPawsConfig.maxDailyCoins).clamp(0.0, 1.0);
    double walletUsdValue = currentCoins * CashPawsConfig.coinToUsdMultiplier;
    double cashoutProgress = (walletUsdValue / CashPawsConfig.targetWithdrawalThreshold).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: CashPawsColors.backgroundLight,
      drawer: const Drawer(
        child: Center(
          child: Text('CashPaws Navigation Menu', style: TextStyle(fontWeight: FontWeight.bold, color: CashPawsColors.textDark)),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: CashPawsColors.textDark),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: _openProfileSettingsWindow, // Fixed: Opens separate profile summary layout center window on tap
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 18, color: CashPawsColors.textDark),
              ),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFE8844), Color(0xFFFF5216)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'DAILY EARNINGS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$currentCoins / ${CashPawsConfig.maxDailyCoins} COINS',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: dailyProgress,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                                        // --- 2. Live Wallet Value Indicator ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: CashPawsColors.cardSurface, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('CURRENT BALANCE: \$${walletUsdValue.toStringAsFixed(2)} USD', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textDark)),
                              Text('Progress to \$${CashPawsConfig.targetWithdrawalThreshold.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: CashPawsColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: cashoutProgress,
                              minHeight: 6,
                              backgroundColor: CashPawsColors.backgroundLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.rewardOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 3. Interactive Task Segment Control Blocks ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: CashPawsColors.cardSurface, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TASK 1: DAILY LOGIN STREAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
                              Icon(Icons.calendar_month, color: CashPawsColors.rewardOrange, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Weekly Calendar Multi-Day Completion Indicator Row Setup
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) => CircleAvatar(
                              radius: 14,
                              backgroundColor: index < 3 ? CashPawsColors.rewardOrange : Colors.grey.shade200,
                              child: Icon(Icons.check, size: 14, color: index < 3 ? Colors.white : Colors.grey),
                            )),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.rewardOrange, foregroundColor: Colors.white, elevation: 0),
                            onPressed: isDailyLimitMaxed ? null : _handleDailyLogin,
                            child: const Text('CLAIM DAILY BONUS COINS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildTaskCard(
                      title: 'TASK 2: WALKING STEPS',
                      subtitle: '$userSteps / 5,000 Steps Today',
                      badgeText: 'Monitoring Graph',
                      buttonText: 'OPEN ACTIVITY TRACKER SCREEN',
                      isDisabled: isDailyLimitMaxed,
                      onTap: _openWalkingStepsWindow, 
                    ),
                    const SizedBox(height: 14),

                    _buildTaskCard(
                      title: 'TASK 3: LUCKY SPIN WHEEL',
                      subtitle: 'Spins Left: $remainingSpins / 5',
                      badgeText: 'Code-Based Wheel Screen',
                      buttonText: 'LAUNCH ANIMATED SPIN MINI-GAME',
                      isDisabled: isDailyLimitMaxed || remainingSpins <= 0,
                      onTap: _openSpinWheelWindow, 
                    ),
                  ],
                ),
              ),
            ),

                        // Anchored Base Footer Ad Footprint for AdMob
            Container(
              width: double.infinity,
              height: 54,
              color: Colors.white,
              alignment: Alignment.center,
              child: AdWidget(
                ad: BannerAd(
                  adUnitId: CashPawsConfig.bannerAdUnitId,
                  size: AdSize.banner,
                  request: const AdRequest(),
                  listener: BannerAdListener(onAdFailedToLoad: (ad, error) => ad.dispose()),
                )..load(),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CashPawsColors.cardSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: CashPawsColors.backgroundLight, borderRadius: BorderRadius.circular(4)),
                child: Text(badgeText, style: const TextStyle(fontSize: 9, color: CashPawsColors.rewardOrange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CashPawsColors.textDark)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.rewardOrange, foregroundColor: Colors.white, elevation: 0),
            onPressed: isDisabled ? null : onTap,
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Draws an 8-segmented flat color prize game wheel on a code-based canvas circle
class BasicWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const segmentAngle = 2 * math.pi / 8;

    for (int i = 0; i < 8; i++) {
      paint.color = (i % 2 == 0) ? const Color(0xFFFE8844) : Colors.amber.shade400;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle,
        segmentAngle,
        true,
        paint,
      );
    }
    // Draw a small central pin caps dot
    paint.color = Colors.white;
    canvas.drawCircle(center, 12, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
