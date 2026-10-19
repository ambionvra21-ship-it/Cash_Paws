import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Operational State counters reset to 0 for live phone testing
  int currentCoins = 0; 
  int remainingSpins = 5; // Fixed to start at 5 full spins
  int userSteps = 4520;
  bool isDailyLimitMaxed = false;

  // AdMob SDK Instance pointers
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  @override
  void initState() {
    super.initState();
    _initAdMobSDK();
  }

  /// Global Initialization and Asset Preloading Sequence
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

    /// Validates reward distributions against the 182 maximum threshold limit
  void _processSecureReward(int amount) {
    if (isDailyLimitMaxed) return;

    setState(() {
      if (currentCoins + amount >= CashPawsConfig.maxDailyCoins) {
        currentCoins = CashPawsConfig.maxDailyCoins;
        isDailyLimitMaxed = true;
        _showLimitReachedMessage();
      } else {
        currentCoins += amount;
      }
    });
  }

  void _showLimitReachedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily coin limit reached! Come back tomorrow to keep earning.'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 4),
      ),
    );
  }

  // --- Task Interaction Core Logic Pipelines ---

  void _handleDailyLogin() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd(); 
          _processSecureReward(CashPawsConfig.coinsDailyLogin);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          _processSecureReward(CashPawsConfig.coinsDailyLogin);
        },
      );
      _interstitialAd!.show();
    } else {
      _loadInterstitialAd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login bonus ad buffering. Tap again in a second!')),
      );
    }
  }

  void _handleWatchVideoReward() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (adWithoutView, rewardItem) {
          _processSecureReward(CashPawsConfig.coinsWalkingSteps);
        },
      );
    } else {
      _loadRewardedAd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video ad is currently buffering. Please try again!')),
      );
    }
  }

  void _handleLuckySpin() {
    if (remainingSpins <= 0 || isDailyLimitMaxed) return;
    setState(() {
      remainingSpins--;
    });
    _processSecureReward(CashPawsConfig.coinsPerLuckySpin);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎰 Spin Complete! Won ${CashPawsConfig.coinsPerLuckySpin} Coins.'),
        backgroundColor: CashPawsColors.rewardOrange,
      ),
    );
  }

  void _handleProfileTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User Profile Settings Screen Coming Soon!')),
    );
  }

  void _handleOfferwallTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Premium Offerwall... Launching Browser Link!')),
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
          child: Text(
            'CashPaws Navigation Menu',
            style: TextStyle(fontWeight: FontWeight.bold, color: CashPawsColors.textDark),
          ),
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
              onTap: _handleProfileTap, // Opened profile handler function mapping
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
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
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
                          const SizedBox(height: 2),
                          Text(
                            isDailyLimitMaxed ? 'DAILY GOAL REACHED [MAXED]' : 'DAILY GOAL TARGET',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
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

                                        // --- 2. Live Wallet Value Conversion Indicator ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'WALLET VALUE',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CURRENT BALANCE: \$${walletUsdValue.toStringAsFixed(2)} USD',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textDark),
                              ),
                              Text(
                                'NEXT PAYOUT: \$${CashPawsConfig.targetWithdrawalThreshold.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textDark),
                              ),
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
                    _buildTaskCard(
                      title: 'TASK 1: DAILY LOGIN STREAK',
                      subtitle: 'Day 5 Bonus',
                      badgeText: 'Triggers Ad',
                      buttonText: 'CLAIM +${CashPawsConfig.coinsDailyLogin} COINS',
                      isDisabled: isDailyLimitMaxed,
                      onTap: _handleDailyLogin,
                    ),
                    const SizedBox(height: 14),

                    _buildTaskCard(
                      title: 'TASK 2: WALKING STEPS',
                      subtitle: '$userSteps / 5,000 Steps Today',
                      badgeText: 'Rewarded Video Ad',
                      buttonText: 'CLAIM ${CashPawsConfig.coinsWalkingSteps} COINS (WATCH VIDEO)',
                      isDisabled: isDailyLimitMaxed,
                      onTap: _handleWatchVideoReward,
                    ),
                    const SizedBox(height: 14),

                    _buildTaskCard(
                      title: 'TASK 3: LUCKY SPIN WHEEL',
                      subtitle: 'Spins Left: $remainingSpins / 5', 
                      badgeText: 'Instant Payout',
                      buttonText: 'SPIN NOW!',
                      isDisabled: isDailyLimitMaxed || remainingSpins <= 0, 
                      onTap: _handleLuckySpin,
                    ),
                    const SizedBox(height: 20),

                    // --- 4. High-Yield Offerwall Alternative Pathway ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'INSTANT CASH SHORTCUT',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
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
                              backgroundColor: CashPawsColors.rewardOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              elevation: 0,
                            ),
                            onPressed: _handleOfferwallTap, // Connected the operational handler method pointer
                            child: const Text('⚡ OPEN PREMIUM OFFERWALL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
              color: Colors.white,
              alignment: Alignment.center,
              child: AdWidget(
                ad: BannerAd(
                  adUnitId: CashPawsConfig.bannerAdUnitId,
                  size: AdSize.banner,
                  request: const AdRequest(),
                  listener: BannerAdListener(
                    onAdFailedToLoad: (ad, error) => ad.dispose(),
                  ),
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
      decoration: BoxDecoration(
        color: CashPawsColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CashPawsColors.backgroundLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badgeText, style: const TextStyle(fontSize: 9, color: CashPawsColors.rewardOrange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CashPawsColors.textDark)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CashPawsColors.rewardOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            onPressed: isDisabled ? null : onTap,
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
