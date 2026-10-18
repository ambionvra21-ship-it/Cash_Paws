import 'dart:async';
import 'package:flutter/material.dart';
import '../services/backend.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

const goal = 5000;

String _clock(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// Daily steps reset at midnight UTC; this gives that moment in the phone's own time.
DateTime _resetAt() {
  final n = DateTime.now().toUtc();
  return DateTime.utc(n.year, n.month, n.day + 1).toLocal();
}

String _resetIn() {
  final d = _resetAt().difference(DateTime.now());
  return '${d.inHours}h ${d.inMinutes % 60}m';
}

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
  DateTime? lastSync;
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
    _timer ??= Timer.periodic(const Duration(seconds: 60), (_) {
      _sync();
      if (mounted) setState(() {}); // keeps the clock fresh
    });
  }

  /// The server decides how many coins the steps are worth.
  /// Automatic syncs are silent; the Sync now button shows what happened.
  Future<void> _sync({bool manual = false}) async {
    final sent = steps;
    final m = manual ? ScaffoldMessenger.of(context) : null;
    if (sent == synced) {
      if (manual) {
        if (mounted) setState(() => lastSync = DateTime.now());
        m!.showSnackBar(SnackBar(
            content: Text(sent == 0 ? 'No steps yet. Walk a few steps, then try again.' : 'Already up to date.')));
      }
      return;
    }
    try {
      final r = await sb.rpc('sync_steps', params: {'p': {'steps': sent}});
      synced = sent;
      if (mounted) setState(() => lastSync = DateTime.now());
      if (manual) {
        final coins = ((r as Map)['coins'] ?? 0) as int;
        m!.showSnackBar(SnackBar(
            content: Text(coins > 0 ? 'Synced! +$coins coins' : 'Synced. ${100 - sent % 100} more steps for the next coin.')));
      }
    } on PostgrestException catch (e) {
      if (manual) m!.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (manual) m!.showSnackBar(const SnackBar(content: Text('Could not sync. Check your internet connection.')));
    }
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
          Text('Time now: ${_clock(DateTime.now())}', style: const TextStyle(color: Colors.white70)),
          Text(lastSync == null ? 'Not synced yet' : 'Last synced: ${_clock(lastSync!)}',
              style: const TextStyle(color: Colors.white70)),
          Text('Steps reset in ${_resetIn()} (at ${_clock(_resetAt())})', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 8, 28, 12),
            child: Text('Steps sync by themselves every 50 steps or each minute. Sync now sends them right away.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          if (problem != null) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Text(problem!, textAlign: TextAlign.center)),
            TextButton(onPressed: _start, child: const Text('Try again')),
            TextButton(onPressed: openAppSettings, child: const Text('Open settings')),
          ] else
            OutlinedButton(onPressed: () => _sync(manual: true), child: const Text('Sync now')),
        ]),
      ),
    );
  }
}
