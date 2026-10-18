import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/backend.dart';
import '../theme.dart';

String fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const tiers = [10, 20, 50, 100, 500, 1000]; // face value in USD, must match the database
  String method = 'GCash', cur = 'PHP';
  int? tier;
  final acct = TextEditingController();
  late final Stream<Map<String, dynamic>> _profile = profileStream();
  late final Future<Map<String, dynamic>> _settings = sb.from('settings').select().single();
  late final Stream<List<Map<String, dynamic>>> _history = sb
      .from('withdrawals')
      .stream(primaryKey: ['id'])
      .eq('user_id', sb.auth.currentUser!.id)
      .order('created_at', ascending: false)
      .limit(20);

  String money(num v, String c) => c == 'PHP' ? '\u20B1${v.toStringAsFixed(2)}' : '\$${v.toStringAsFixed(2)}';

  double payout(int t, Map<String, dynamic> s, String c) {
    final rate = c == 'PHP' ? (s['usd_php'] as num).toDouble() : 1.0;
    return t * (s['payout_share_pct'] as num) / 100 * rate;
  }

  void _snack(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _submit(Map<String, dynamic> s) async {
    final t = tier;
    if (t == null) return _snack('Choose a withdrawal amount');
    final cost = t * (s['coins_per_usd'] as int);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirm withdrawal'),
        content: Text('This uses ${fmt(cost)} coins (face value \$$t).\n\n'
            'You will receive ${money(payout(t, s, cur), cur)} via $method '
            '(${s['payout_share_pct']}% of the face value).\n\nThis cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final r = await callFn(context, 'requestWithdrawal', {
      'method': method,
      'account': acct.text.trim(),
      'tier': t,
      'currency': cur,
    });
    if (r != null && mounted) {
      setState(() => tier = null);
      _snack('Withdrawal requested');
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _settings,
          builder: (_, ss) {
            if (!ss.hasData) return const Center(child: CircularProgressIndicator());
            final s = ss.data!;
            final cpu = s['coins_per_usd'] as int;
            final share = s['payout_share_pct'] as int;
            return ListView(padding: const EdgeInsets.all(20), children: [
              StreamBuilder<Map<String, dynamic>>(
                stream: _profile,
                builder: (_, ps) {
                  final coins = ((ps.data?['coins'] ?? 0) as num).toInt();
                  final first = tiers.first * cpu;
                  return Column(children: [
                    Text(fmt(coins), style: const TextStyle(fontSize: 44, color: kNeon, shadows: [Shadow(color: kNeon, blurRadius: 18)])),
                    const Text('paw coins', style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 8),
                    Text('${fmt(cpu)} coins = \$1.00 face value. You receive $share% of the face value when you withdraw.',
                        textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: (coins / first).clamp(0, 1).toDouble(), color: kNeon, backgroundColor: kLine),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(coins >= first ? 'Pick a tier below' : 'First tier unlocks at ${fmt(first)} coins',
                          style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    ),
                    const SizedBox(height: 16),
                    Align(alignment: Alignment.centerLeft, child: Text('Choose amount (face value)', style: TextStyle(color: Colors.white.withOpacity(.8)))),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final t in tiers)
                        ChoiceChip(
                          label: Text('\$$t'),
                          selected: tier == t,
                          onSelected: coins >= t * cpu ? (_) => setState(() => tier = t) : null,
                        ),
                    ]),
                  ]);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const ['GCash', 'Maya', 'One'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() {
                  method = v!;
                  if (method == 'GCash' || method == 'Maya') cur = 'PHP';
                }),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [ButtonSegment(value: 'USD', label: Text('USD')), ButtonSegment(value: 'PHP', label: Text('PHP'))],
                selected: {cur},
                onSelectionChanged: (method == 'GCash' || method == 'Maya') ? null : (v) => setState(() => cur = v.first),
              ),
              if (method == 'GCash' || method == 'Maya')
                const Padding(padding: EdgeInsets.only(top: 6), child: Text('GCash and Maya pay out in PHP.', style: TextStyle(color: Colors.white54, fontSize: 12))),
              if (method == 'One')
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Don\u2019t have One yet? Register and download it, then use code V98HAR.', style: TextStyle(color: kNeon)),
                ),
              const SizedBox(height: 10),
              TextField(controller: acct, decoration: const InputDecoration(labelText: 'Account number or email')),
              const SizedBox(height: 14),
              if (tier != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: kNeon), borderRadius: BorderRadius.circular(12)),
                  child: Text('Costs ${fmt(tier! * cpu)} coins \u00b7 You receive ${money(payout(tier!, s, cur), cur)} ($share% of \$$tier)',
                      style: const TextStyle(color: kNeon, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 14),
              FilledButton(onPressed: () => _submit(s), child: const Text('Request withdrawal')),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Requests are reviewed by hand and can take up to 7 days. 18+ only. One pending request at a time. '
                    'New accounts can withdraw after ${s['min_account_days']} days. Rates and the PHP exchange rate may change; '
                    'the rate shown when you confirm is the rate you get.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const SizedBox(height: 24),
              const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _history,
                builder: (_, hs) {
                  final rows = hs.data ?? [];
                  if (rows.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No withdrawals yet'));
                  return Column(
                    children: rows.map((w) {
                      final st = '${w['status']}';
                      final pay = w['payout'] == null ? '' : '${money(w['payout'] as num, '${w['currency']}')} \u00b7 ';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('$pay${w['method']}'),
                        subtitle: Text('${fmt((w['amount'] as num).toInt())} coins'),
                        trailing: Text(st[0].toUpperCase() + st.substring(1)),
                      );
                    }).toList(),
                  );
                },
              ),
            ]);
          },
        ),
      );
}
