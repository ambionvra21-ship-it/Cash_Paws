import 'package:flutter/material.dart';
import '../theme.dart';

const kGreen = Color(0xFF2DFFB0);

/// Big neon gradient button.
class GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const GlowButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final on = onPressed != null;
    return Opacity(
      opacity: on ? 1 : .45,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kNeon, kNeon2]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: on ? [BoxShadow(color: kNeon.withOpacity(.45), blurRadius: 22, offset: const Offset(0, 6))] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, color: const Color(0xFF001018), size: 20), const SizedBox(width: 8)],
                Text(label, style: const TextStyle(color: Color(0xFF001018), fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card with a soft neon border and glow.
class NeonCard extends StatelessWidget {
  final Widget child;
  const NeonCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0E1A30), kSurface]),
          border: Border.all(color: kLine),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: kNeon.withOpacity(.08), blurRadius: 24)],
        ),
        child: child,
      );
}

/// Circular progress ring with a label in the middle.
class NeonRing extends StatelessWidget {
  final double value;
  final String label;
  final double size;
  const NeonRing({super.key, required this.value, required this.label, this.size = 110});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: kGreen.withOpacity(.25), blurRadius: 22)]),
        child: Stack(fit: StackFit.expand, children: [
          CircularProgressIndicator(value: value.clamp(0, 1).toDouble(), strokeWidth: 10, backgroundColor: kLine, color: kGreen),
          Center(child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
        ]),
      );
}
