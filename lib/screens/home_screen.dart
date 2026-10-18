import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/backend.dart';
import '../theme.dart';
import '../widgets/glow.dart';
import 'profile_screen.dart';

// id, title, goal, reward (must match the database)
const missions = [
  ('login', 'Claim daily login', 1, 5),
  ('steps', 'Walk 2,000 steps', 2000, 10),
  ('ads', 'Watch 3 reward ads', 3, 10),
  ('spin', 'Spin the wheel', 1, 5),
];
const medals = ['\u{1F947}', '\u{1F948}', '\u{1F949}'];

int _n(dynamic v) => v is num ? v.toInt() : 0;
String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

int _prog(String id, Map<String, dynamic> d, String t) {
  switch (id) {
    case 'login': return d['last'] == t ? 1 : 0;
    case 'steps': return d['stepsDay'] == t ? _n(d['steps']) : 0;
    case 'ads': return d['adsDay'] == t ? _n(d['ads']) : 0;
    default: return d['spinDay'] == t ? 1 : 0;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _rank = 0;
  late final Stream<Map<String, dynamic>> _profile = profileStream();
  late final Future<List<dynamic>> _lb = _loadLb();

  Future<List<dynamic>> _loadLb() async {
    final r = await sb.rpc('get_leaderboard', params: {'p': {}});
    final m = Map<String, dynamic>.from(r as Map);
    _rank = m['rank'] as int;
    return m['top'] as List<dynamic>;
  }

  Widget _day(int i, int doneDays, bool claimed) {
    final isDone = i <= doneDays;
    final isToday = !claimed && i == doneDays + 1;
    final accent = isToday ? kGreen : kNeon;
    final IconData icon = isDone ? Icons.check : (i == 7 ? Icons.card_giftcard : (isToday ? Icons.bolt : Icons.lock_outline));
    return Column(children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? kNeon.withOpacity(.14) : Colors.transparent,
          border: Border.all(color: (isDone || isToday) ? accent : Colors.white24, width: isToday ? 2 : 1.5),
          boxShadow: (isDone || isToday) ? [BoxShadow(color: accent.withOpacity(.4), blurRadius: 10)] : null,
        ),
        child: Icon(icon, size: 18, color: (isDone || isToday) ? accent : Colors.white38),
      ),
      const SizedBox(height: 6),
      Text('Day $i', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: (isDone || isToday) ? Colors.white : Colors.white38)),
    ]);
  }

  Widget _mission((String, String, int, int) m, Map<String, dynamic> d, String t, List<String> done) {
    final isDone = done.contains(m.$1);
    final p = _prog(m.$1, d, t);
    final ready = p >= m.$3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? kGreen : Colors.white38, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.$2, style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? Colors.white54 : Colors.white)),
            Text('${p.clamp(0, m.$3)}/${m.$3}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ]),
        ),
        if (!isDone)
          SizedBox(
            height: 34,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16), minimumSize: const Size(56, 34)),
              onPressed: ready ? () => callFn(context, 'claimMission', {'id': m.$1}) : null,
              child: Text('+${m.$4}'),
            ),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return SafeArea(
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _profile,
        builder: (_, s) {
          final d = s.data ?? <String, dynamic>{};
          final coins = _n(d['coins']);
          final streak = _n(d['streak']);
          final claimed = d['last'] == t;
          final freeze = d['freeze'] == null ? 1 : _n(d['freeze']);
          final done = d['missionsDay'] == t ? List<String>.from(d['missions'] ?? []) : <String>[];
          final doneCount = missions.where((m) => done.contains(m.$1)).length;
          final all4 = doneCount == missions.length;
          final cycleDone = (claimed && streak > 0) ? ((streak - 1) % 7) + 1 : streak % 7;
          return ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 24), children: [
            Row(children: [
              Image.asset('assets/splash.png', width: 34),
              const SizedBox(width: 8),
              const Text('CashPaws', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kNeon, shadows: [Shadow(color: kNeon, blurRadius: 12)])),
              const Spacer(),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kNeon), boxShadow: [BoxShadow(color: kNeon.withOpacity(.4), blurRadius: 10)]),
                  child: CircleAvatar(backgroundColor: kSurface, child: Text(d['av'] ?? '\u{1F431}', style: const TextStyle(fontSize: 22))),
                ),
              ),
            ]),
            const SizedBox(height: 18),
            Center(
              child: Column(children: [
                const Text('Your balance', style: TextStyle(color: Colors.white54)),
                Text(_fmt(coins), style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w800, color: kNeon, shadows: [Shadow(color: kNeon, blurRadius: 28)])),
                const Text('paw coins', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 6),
                Text('\u{1F525} $streak day streak', style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
            NeonCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Daily login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Claim every day to grow your streak. Day 7 pays a bonus.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 14),
                Row(children: [for (var i = 1; i <= 7; i++) Expanded(child: _day(i, cycleDone, claimed))]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GlowButton(
                    label: claimed ? 'Come back tomorrow' : "Claim Today's Reward",
                    icon: claimed ? null : Icons.card_giftcard,
                    onPressed: claimed ? null : () => callFn(context, 'claimDaily'),
                  ),
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text('\u{1F9CA} Streak freeze: $freeze (saves a missed day)', style: const TextStyle(fontSize: 12, color: Colors.white70))),
                  TextButton(onPressed: freeze >= 2 ? null : () => callFn(context, 'buyFreeze'), child: const Text('Buy \u00b7 300')),
                ]),
              ]),
            ),
            NeonCard(
              child: Column(children: [
                const Text('Daily missions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                const Text('Finish all four for a +20 bonus.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 14),
                NeonRing(value: doneCount / missions.length, label: '$doneCount/${missions.length}'),
                const SizedBox(height: 10),
                for (final m in missions) _mission(m, d, t, done),
                if (all4 && !done.contains('bonus')) ...[
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: GlowButton(label: 'Claim bonus +20', icon: Icons.emoji_events, onPressed: () => callFn(context, 'claimMission', {'id': 'bonus'}))),
                ],
              ]),
            ),
            NeonCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Weekly top earners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Text('Resets every Monday', style: TextStyle(color: Colors.white54, fontSize: 12)),
                FutureBuilder<List<dynamic>>(
                  future: _lb,
                  builder: (_, ls) {
                    if (ls.hasError) return const Padding(padding: EdgeInsets.all(12), child: Text('Leaderboard unavailable right now'));
                    if (!ls.hasData) return const Padding(padding: EdgeInsets.all(12), child: Text('Loading...'));
                    final top = ls.data!;
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.only(top: 6), child: Text('You are #$_rank', style: const TextStyle(color: kNeon, fontSize: 13, fontWeight: FontWeight.w600))),
                      for (var i = 0; i < top.length; i++)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(i < 3 ? medals[i] : '${i + 1}.', style: const TextStyle(fontSize: 18)),
                          title: Text('${top[i]['av']} ${top[i]['name']}', style: TextStyle(color: top[i]['me'] == true ? kNeon : null, fontWeight: top[i]['me'] == true ? FontWeight.bold : null)),
                          trailing: Text('${top[i]['total']}'),
                        ),
                    ]);
                  },
                ),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}
