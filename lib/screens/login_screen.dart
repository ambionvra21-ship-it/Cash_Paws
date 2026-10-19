import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../services/backend.dart';
import '../theme.dart';
import '../widgets/glow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool busy = false;

  Future<void> _open(String url) async {
    try {
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && mounted) _msg('Could not open the page.');
    } catch (_) {
      if (mounted) _msg('Could not open the page.');
    }
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _run(Future<void> Function() job) async {
    setState(() => busy = true);
    try {
      await job();
    } on AuthException catch (e) {
      _msg(e.message);
    } catch (_) {
      _msg('Something went wrong. Check your internet connection.');
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> _signIn() => _run(() async {
        await sb.auth.signInWithPassword(email: email.text.trim(), password: pass.text);
      });

  Future<void> _signUp() => _run(() async {
        final e = email.text.trim();
        if (!e.contains('@') || pass.text.length < 6) {
          _msg('Enter a valid email and a password of at least 6 characters.');
          return;
        }
        final r = await sb.auth.signUp(email: e, password: pass.text);
        if (r.session == null) _msg('Account created. Check your email to confirm it, then sign in.');
      });

  Future<void> _google() => _run(() async {
        try {
          final g = await GoogleSignIn(serverClientId: kGoogleWebClientId).signIn();
          if (g == null) return;
          final a = await g.authentication;
          if (a.idToken == null) throw 'No ID token';
          await sb.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: a.idToken!, accessToken: a.accessToken);
        } catch (_) {
          _msg('Google sign-in failed. Use email instead.');
        }
      });

  Future<void> _guest() => _run(() async {
        await sb.auth.signInAnonymously();
      });

  @override
  Widget build(BuildContext context) {
    final googleReady = !kGoogleWebClientId.startsWith('YOUR-');
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset('assets/splash.png', width: 100),
              const SizedBox(height: 4),
              const Text('CashPaws',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: kNeon, shadows: [Shadow(color: kNeon, blurRadius: 18)])),
              const SizedBox(height: 22),
              TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: GlowButton(label: 'Sign in', onPressed: busy ? null : _signIn)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: busy ? null : _signUp, child: const Text('Create account')),
              ),
              if (googleReady)
                TextButton(onPressed: busy ? null : _google, child: const Text('Continue with Google')),
              TextButton(onPressed: busy ? null : _guest, child: const Text('Continue as guest')),
              Wrap(alignment: WrapAlignment.center, children: [
                TextButton(onPressed: () => _open(kTermsUrl), child: const Text('Terms of Use', style: TextStyle(fontSize: 12))),
                TextButton(onPressed: () => _open(kPrivacyUrl), child: const Text('Privacy Policy', style: TextStyle(fontSize: 12))),
              ]),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Guests can\u2019t use referral codes and may lose their coins if they uninstall.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
