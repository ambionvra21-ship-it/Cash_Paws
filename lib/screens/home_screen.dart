import 'package:flutter/material.dart';
import '../services/backend.dart';
import '../services/api.dart';
import '../theme.dart';
import 'profile_screen.dart';

// id, title, goal, reward (must match functions/index.js)
const missions = [
  ('login', 'Claim daily login', 1, 5),
  ('steps', 'Walk 2,000 steps', 2000, 10),
  ('ads', 'Watch 3 ads', 3, 10),
  ('spin', 'Spin the wheel', 1, 5),
];
const medals = ['\u{1F947}', '\u{1F948}', '\u{1F949}'];

int _n(dynamic v) => v is num ? v.toInt() : 0;

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
  late final Future<List<dynamic>> _lb = _loadLb();

  Future<List<dynamic>> _loadLb() async {
    final r = await sb.rpc('get_leaderboard', params: {'p': {}});
    final m = Map<String, dynamic>.from(r as Map);
    _rank = m['rank'] as int;
    return m['top'] as List<dynamic>;
  }

  Widget _card(List<Widget> children) => Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kSurface, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  @override
  Widget build(BuildContext context) {
    final t = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return SafeArea(
      child: StreamBuilder<Map<String, dynamic>>(
        stream: profileStream(),
        builder: (_, s) {
          final d = s.data ?? <String, dynamic>{};
          final claimed = d['last'] == t;
          final freeze = d['freeze'] == null ? 1 : _n(d['freeze']);
          final done = d['missionsDay'] == t ? List<String>.from(d['missions'] ?? []) : <String>[];
          final all4 = missions.every((m) => done.contains(m.$1));
          return ListView(padding: const EdgeInsets.all(20), children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: CircleAvatar(backgroundColor: kSurface, child: Text(d['av'] ?? '\u{1F431}', style: const TextStyle(fontSize: 22))),
              ),
            ),
            Center(child: Column(children: [
              const Text('Your balance', style: TextStyle(color: Colors.white54)),
              Text('${_n(d['coins'])}', style: const TextStyle(fontSize: 56, color: kNeon, shadows: [Shadow(color: kNeon, blurRadius: 22)])),
              Text('\u{1F525} ${_n(d['streak'])} day streak'),
            ])),
            _card([
              const Text('Daily login', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: claimed ? null : () => callFn(context, 'claimDaily'),
                  child: Text(claimed ? 'Come back tomorrow' : 'Claim daily reward'),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\u{1F9CA} Streak freeze: $freeze (saves a missed day)', style: const TextStyle(fontSize: 12)),
                TextButton(onPressed: freeze >= 2 ? null : () => callFn(context, 'buyFreeze'), child: const Text('Buy \u00b7 300')),
              ]),
            ]),
            _card([
              const Text('Daily missions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const Text('Finish all four for a +20 bonus.', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: missions.where((m) => done.contains(m.$1)).length / 4, color: const Color(0xFF2DFFB0), backgroundColor: kLine),
              for (final m in missions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.$2),
                  subtitle: Text('${_prog(m.$1, d, t).clamp(0, m.$3)}/${m.$3}'),
                  trailing: done.contains(m.$1)
                      ? const Icon(Icons.check_circle, color: Color(0xFF2DFFB0))
                      : FilledButton.tonal(
                          onPressed: _prog(m.$1, d, t) >= m.$3 ? () => callFn(context, 'claimMission', {'id': m.$1}) : null,
                          child: Text('+${m.$4}'),
                        ),
                ),
              if (all4 && !done.contains('bonus'))
                FilledButton(onPressed: () => callFn(context, 'claimMission', {'id': 'bonus'}), child: const Text('Claim bonus +20')),
            ]),
            _card([
              const Text('Weekly top earners', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const Text('Resets every Monday', style: TextStyle(color: Colors.white54, fontSize: 12)),
              FutureBuilder<List<dynamic>>(
                future: _lb,
                builder: (_, s) {
                  if (!s.hasData) return const Padding(padding: EdgeInsets.all(12), child: Text('Loading...'));
                  final top = s.data!;
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('You are #$_rank', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
          ]);
        },
      ),
    );
  }
}
