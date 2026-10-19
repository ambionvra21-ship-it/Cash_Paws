class CashPawsConfig {
  // Profit stabilization reward constraints
  static const int maxDailyCoins = 182;
  static const int maxAdMobCoins = 100;
  static const int maxAppLovinCoins = 82;

  // Task-specific token values
  static const int coinsDailyLogin = 10;
  static const int coinsWalkingSteps = 20;
  static const int coinsPerLuckySpin = 5;

  // Financial monetary multiplier ($0.001 per coin)
  static const double coinToUsdMultiplier = 0.001;
  static const double targetWithdrawalThreshold = 2.00;

  // Placeholder Admob Network Deployment Strings
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
}
