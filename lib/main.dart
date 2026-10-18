import 'package:flutter/material.dart';
import 'package:cashpaws/screens/home_screen.dart';
import 'package:cashpaws/screens/walk_screen.dart';
import 'package:cashpaws/screens/wallet_screen.dart';

void main() {
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPaws',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Standard dark mode to bypass the 'cashPawsTheme' undefined error
      home: const HomeScreen(), // Launches your newly upgraded dashboard first
      routes: {
        '/home': (context) => const HomeScreen(),
        '/walk': (context) => const WalkScreen(),
        '/wallet': (context) => const WalletScreen(),
      },
    );
  }
}
