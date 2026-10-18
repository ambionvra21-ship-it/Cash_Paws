import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

const _slides = [
  ('\u{1F43E}', 'Welcome to CashPaws', 'Earn coins every day with simple tasks.'),
  ('\u{1F45F}', 'Walk, watch and spin', 'Steps, short ads, daily spins and missions all add up.'),
  ('\u{1F4B8}', 'Cash out', 'Withdraw to GCash, Maya or One.'),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _c = PageController();
  int i = 0;

  Future<void> _finish() async {
    (await SharedPreferences.getInstance()).setBool('onboarded', true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: PageView.builder(
                controller: _c,
                itemCount: _slides.length,
                onPageChanged: (v) => setState(() => i = v),
                itemBuilder: (_, k) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_slides[k].$1, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    Text(_slides[k].$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kNeon)),
                    const SizedBox(height: 8),
                    Text(_slides[k].$3, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                  ]),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var k = 0; k < _slides.length; k++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  width: k == i ? 22 : 8, height: 8,
                  decoration: BoxDecoration(color: k == i ? kNeon : kLine, borderRadius: BorderRadius.circular(9)),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: i < _slides.length - 1 ? () => _c.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut) : _finish,
                  child: Text(i < _slides.length - 1 ? 'Next' : 'Get started'),
                ),
              ),
            ),
          ]),
        ),
      );
}
