import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'backend.dart';

/// Google's official TEST ad units. Replace with your own before release.
class AdIds {
  static const banner = 'ca-app-pub-3940256099942544/6300978111';
  static const rewarded = 'ca-app-pub-3940256099942544/5224354917';
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});
  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _ready = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: _ready ? AdWidget(ad: _ad!) : const SizedBox.shrink(),
      );
}

class RewardedService {
  static void showAndClaim(BuildContext context) {
    final m = ScaffoldMessenger.of(context);
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => ad.show(onUserEarnedReward: (_, __) async {
          try {
            await sb.rpc('reward_ad', params: {'p': {}});
            m.showSnackBar(const SnackBar(content: Text('+5 coins')));
          } on PostgrestException catch (e) {
            m.showSnackBar(SnackBar(content: Text(e.message)));
          }
        }),
        onAdFailedToLoad: (_) =>
            m.showSnackBar(const SnackBar(content: Text('No ad available. Try again soon.'))),
      ),
    );
  }
}
