import 'package:flutter/material.dart';
import '../services/backend.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api.dart';
import '../theme.dart';

const avatars = ['\u{1F431}', '\u{1F436}', '\u{1F98A}', '\u{1F43C}', '\u{1F42F}', '\u{1F438}', '\u{1F981}', '\u{1F435}'];
const levelTitles = ['Pup', 'Scout', 'Walker', 'Hunter', 'Champion'];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  bool _loaded = false;

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await sb.auth.signOut();
    } catch (_) {}
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('Your coins, history and referral code will be erased. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B8A)))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (await callFn(context, 'deleteAccount') != null) await _signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: kSurface),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: profileStream(),
        builder: (_, s) {
          final d = s.data ?? <String, dynamic>{};
          if (!_loaded && s.hasData) {
            name.text = d['name'] ?? 'Paw Friend';
            _loaded = true;
          }
          final total = (d['total'] ?? 0) as num;
          final lv = total ~/ 500 + 1, into = (total % 500).toInt();
          return ListView(padding: const EdgeInsets.all(20), children: [
            Center(child: CircleAvatar(radius: 44, backgroundColor: kSurface, child: Text(d['av'] ?? '\u{1F431}', style: const TextStyle(fontSize: 46)))),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              maxLength: 16,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Display name',
                suffixIcon: IconButton(icon: const Icon(Icons.check), onPressed: () => callFn(context, 'updateProfile', {'name': name.text})),
              ),
            ),
            Center(child: Text('Level $lv \u00b7 ${levelTitles[(lv - 1).clamp(0, 4)]}', style: const TextStyle(color: kNeon, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: into / 500, color: kNeon, backgroundColor: kLine),
            Center(child: Padding(padding: const EdgeInsets.only(top: 4), child: Text('$into / 500 XP to level ${lv + 1}', style: const TextStyle(color: Colors.white54, fontSize: 12)))),
            const SizedBox(height: 20),
            const Text('Choose avatar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final a in avatars)
                InkWell(
                  onTap: () => callFn(context, 'updateProfile', {'av': a}),
                  child: Container(
                    width: 64, height: 56, alignment: Alignment.center,
                    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: d['av'] == a ? kNeon : kLine)),
                    child: Text(a, style: const TextStyle(fontSize: 28)),
                  ),
                ),
            ]),
            const SizedBox(height: 20),
            ListTile(title: const Text('Total earned'), trailing: Text('$total')),
            ListTile(title: const Text('Friends joined'), trailing: Text('${d['refs'] ?? 0}')),
            ListTile(title: const Text('Member since'), trailing: Text('${d['joined'] ?? '-'}')),
            ListTile(title: const Text('Referral code'), trailing: Text('${d['code'] ?? '-'}', style: const TextStyle(color: kNeon))),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('One account per device. Duplicate or fake accounts are removed.', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            OutlinedButton(onPressed: _signOut, child: const Text('Log out')),
            TextButton(onPressed: _delete, child: const Text('Delete account', style: TextStyle(color: Color(0xFFFF6B8A)))),
          ]);
        },
      ),
    );
  }
}
