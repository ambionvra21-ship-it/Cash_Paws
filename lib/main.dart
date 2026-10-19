import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure that Flutter widget binding hooks are securely established
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the Google Mobile Ads SDK operational engine
  await MobileAds.instance.initialize();
  
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPaws',
      debugShowCheckedModeBanner: false,
      
      // Inject our verified neon-green dark mode scheme properties
      theme: CashPawsTheme.darkTheme,
      
      // Lock down the permanent initial landing route destination
      home: const HomeScreen(),
    );
  }
}
