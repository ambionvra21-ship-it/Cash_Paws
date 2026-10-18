import 'package:cashpaws/screens/home_screen.dart';
import 'package:cashpaws/screens/walk_screen.dart';
import 'package:cashpaws/screens/wallet_screen.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'services/backend.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/ads_screen.dart';
import 'screens/home_screen.dart';
import 'screens/invite_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/walk_screen.dart';
import 'screens/spin_screen.dart';
import 'screens/wallet_screen.dart';
import 'services/ads_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
  await MobileAds.instance.initialize();
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CashPaws',
        debugShowCheckedModeBanner: false,
        theme: cashPawsTheme,
        home: const Gate(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  static const pages = <Widget>[
    HomeScreen(),
    WalkScreen(),
    AdsScreen(),
    SpinScreen(),
    InviteScreen(),
    WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: pages[i],
        bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
          const BannerAdWidget(), // AdMob banner space
          NavigationBar(
            selectedIndex: i,
            onDestinationSelected: (v) => setState(() => i = v),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.directions_walk), label: 'Walk'),
              NavigationDestination(icon: Icon(Icons.ondemand_video), label: 'Ads'),
              NavigationDestination(icon: Icon(Icons.casino_outlined), label: 'Spin'),
              NavigationDestination(icon: Icon(Icons.group_add_outlined), label: 'Invite'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
            ],
          ),
        ]),
      );
}

/// Shows onboarding once, then login or the main app.
class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool? onboarded;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => onboarded = p.getBool('onboarded') ?? false));
  }

  @override
  Widget build(BuildContext context) {
    if (onboarded == null) return const Scaffold();
    if (!onboarded!) return OnboardingScreen(onDone: () => setState(() => onboarded = true));
    return StreamBuilder<AuthState>(
      stream: sb.auth.onAuthStateChange,
      builder: (_, __) => sb.auth.currentSession == null ? const LoginScreen() : const Shell(),
    );
  }
}
