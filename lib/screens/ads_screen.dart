import 'package:flutter/material.dart';
import '../services/ads_service.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: FilledButton(
          onPressed: () => RewardedService.showAndClaim(context),
          child: const Text('Watch ad (+5)'),
        ),
      );
}
