import 'package:flutter/material.dart';
import '../services/backend.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../config.dart';
import '../services/api.dart';
import '../theme.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  late final Future<String> _code = sb.rpc('ensure_profile', params: {'p': {}}).then((r) => (r as Map)['code'] as String);
  final entry = TextEditingController();

  Future<void> _apply() async {
    final r = await callFn(context, 'applyReferral', {'code': entry.text});
    if (r != null && mounted) {
      entry.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+50 coins')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Invite friends', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text('You get 100 coins for each friend who joins with your code. They get 50.',
            style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 16),
        FutureBuilder<String>(
          future: _code,
          builder: (_, s) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: kNeon), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(s.data ?? '------', style: const TextStyle(fontSize: 24, letterSpacing: 3, color: kNeon)),
              TextButton(
                onPressed: s.hasData
                    ? () {
                        Clipboard.setData(ClipboardData(text: s.data!));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
                      }
                    : null,
                child: const Text('Copy'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.share),
          label: const Text('Share invite'),
          onPressed: () async {
            final code = await _code;
            Share.share('Join me on CashPaws and earn rewards! Use my code $code.\nDownload: $kPlayStoreUrl');
          },
        ),
        const SizedBox(height: 16),
        StreamBuilder<Map<String, dynamic>>(
        stream: profileStream(),
          builder: (_, s) {
            final d = s.data ?? {};
            return Row(children: [
              Expanded(child: _stat('${d['refs'] ?? 0}', 'friends joined')),
              const SizedBox(width: 10),
              Expanded(child: _stat('${d['refEarned'] ?? 0}', 'coins earned')),
            ]);
          },
        ),
        const SizedBox(height: 24),
        const Text('Got a friend\u2019s code?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Enter it once to claim 50 coins. Sign in with Google to use a code.',
            style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 10),
        TextField(controller: entry, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Enter code')),
        const SizedBox(height: 10),
        FilledButton(onPressed: _apply, child: const Text('Apply code')),
      ]),
    );
  }

  Widget _stat(String v, String l) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kSurface, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(v, style: const TextStyle(fontSize: 24, color: kNeon)),
          Text(l, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      );
}
