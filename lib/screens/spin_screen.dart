import 'dart:math';
import 'package:flutter/material.dart';
import '../services/backend.dart';
import '../services/api.dart';
import '../theme.dart';

const prizes = [1, 5, 2, 10, 3, 25, 2, 50]; // must match functions/index.js

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});
  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  double _turns = 0;
  bool _busy = false;
  int _prize = 0;

  Future<void> _spin() async {
    setState(() => _busy = true);
    final r = await callFn(context, 'spinWheel'); // server picks the prize
    if (r == null) {
      setState(() => _busy = false);
      return;
    }
    final i = r['index'] as int;
    _prize = r['prize'] as int;
    setState(() => _turns = _turns.floorToDouble() + 5 + (1 - (i * 45 + 22.5) / 360));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Daily spin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Icon(Icons.arrow_drop_down, size: 44, color: Color(0xFF2DFFB0)),
          SizedBox(
            width: 250,
            height: 250,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _turns),
              duration: const Duration(seconds: 4),
              curve: Curves.easeOutCubic,
              onEnd: () {
                setState(() => _busy = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+$_prize coins')));
              },
              builder: (_, v, child) => Transform.rotate(angle: v * 2 * pi, child: child),
              child: CustomPaint(painter: WheelPainter()),
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<Map<String, dynamic>>(
        stream: profileStream(),
            builder: (_, s) {
              final spun = s.data?['spinDay'] == today;
              return FilledButton(
                onPressed: (spun || _busy) ? null : _spin,
                child: Text(spun && !_busy ? 'Come back tomorrow' : 'Spin the wheel'),
              );
            },
          ),
        ])),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    for (var i = 0; i < 8; i++) {
      final start = -pi / 2 + i * pi / 4;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, pi / 4, true,
          Paint()..color = i.isEven ? const Color(0xFF0D2347) : const Color(0xFF123B7A));
      final a = start + pi / 8;
      final tp = TextPainter(
        text: TextSpan(text: '${prizes[i]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c + Offset(cos(a), sin(a)) * r * 0.7 - Offset(tp.width / 2, tp.height / 2));
    }
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = kNeon);
  }

  @override
  bool shouldRepaint(_) => false;
}
