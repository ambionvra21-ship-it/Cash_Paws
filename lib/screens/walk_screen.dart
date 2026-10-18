import 'dart:async';
import 'package:flutter/material.dart';
import '../services/backend.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

const goal = 5000;

String _today() => DateTime.now().toUtc().toIso8601String().substring(0, 10);

/// The phone sensor counts steps since boot. Turn that into "steps today".
Future<int> _todaySteps(int counter) async {
  final p = await SharedPreferences.getInstance();
  if (p.getString('day') != _today()) {
    await p.setString('day', _today());
    await p.setInt('base', counter);
    await p.setInt('carry', 0);
    await p.setInt('last', 0);
  }
  var base = p.getInt('base')!, carry = p.getInt('carry')!;
  if (counter < base) {
    // phone rebooted: keep what we had, restart from the new counter
    carry = p.getInt('last') ?? 0;
    base = counter;
    await p.setInt('base', base);
    await p.setInt('carry', carry);
  }
  final today = carry + counter - base;
  await p.setInt('last', today);
  return today;
}

class WalkScreen extends StatefulWidget {
  const WalkScreen({super.key});
  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen> {
  StreamSubscription<StepCount>? _sub;
  Timer? _timer;
  int steps = 0, synced = 0;
  String? problem;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final st = await Permission.activityRecognition.request();
    if (!st.isGranted) {
      if (mounted) setState(() => problem = 'Allow physical activity access to count your steps.');
      return;
    }
    if (mounted) setState(() => problem = null);
    _sub?.cancel();
    _sub = Pedometer.stepCountStream.listen((e) async {
      final s = await _todaySteps(e.steps);
      if (!mounted) return;
      setState(() => steps = s);
      if (s - synced >= 50) _sync();
    }, onError: (_) {
      if (mounted) setState(() => problem = 'This phone has no step sensor.');
    });
    _timer ??= Timer.periodic(const Duration(seconds: 60), (_) => _sync());
  }

  /// The server decides how many coins the steps are worth.
  Future<void> _sync() async {
    final sent = steps;
    if (sent == synced) return;
    try {
      await sb.rpc('sync_steps', params: {'p': {'steps': sent}});
      synced = sent;
    } catch (_) {/* retry on next tick */}
  }

  @override
  void dispose() {
    _sync();
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Walk and earn', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('1 coin for every 100 steps', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(
                value: (steps / goal).clamp(0, 1).toDouble(),
                strokeWidth: 12,
                backgroundColor: kLine,
                color: kNeon,
              ),
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$steps', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                  const Text('of 5,000 steps', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          StreamBuilder<Map<String, dynamic>>(
        stream: profileStream(),
            builder: (_, s) {
              final d = s.data ?? {};
              final paid = d['stepsDay'] == _today() ? (d['stepsPaid'] ?? 0) : 0;
              return Text('$paid coins earned from steps today', style: const TextStyle(color: kNeon));
            },
          ),
          const SizedBox(height: 16),
          if (problem != null) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Text(problem!, textAlign: TextAlign.center)),
            TextButton(onPressed: _start, child: const Text('Try again')),
            TextButton(onPressed: openAppSettings, child: const Text('Open settings')),
          ] else
            OutlinedButton(onPressed: _sync, child: const Text('Sync now')),
        ]),
      ),
    );
  }
}
