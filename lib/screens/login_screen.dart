import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../services/backend.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _google(BuildContext c) async {
    final m = ScaffoldMessenger.of(c);
    try {
      final g = await GoogleSignIn(serverClientId: kGoogleWebClientId).signIn();
      if (g == null) return;
      final a = await g.authentication;
      if (a.idToken == null) throw 'No ID token';
      await sb.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: a.idToken!, accessToken: a.accessToken);
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Google sign-in failed. Check the Google setup in the README.')));
    }
  }

  Future<void> _guest(BuildContext c) async {
    final m = ScaffoldMessenger.of(c);
    try {
      await sb.auth.signInAnonymously();
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Guest sign-in is off. Turn on anonymous sign-ins in Supabase.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset('assets/splash.png', width: 120),
              const SizedBox(height: 8),
              const Text('CashPaws',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: kNeon,
                      shadows: [Shadow(color: kNeon, blurRadius: 18)])),
              const SizedBox(height: 28),
              FilledButton(onPressed: () => _google(context), child: const Text('Continue with Google')),
              TextButton(onPressed: () => _guest(context), child: const Text('Continue as guest')),
            ]),
          )),
        ),
      );
}
