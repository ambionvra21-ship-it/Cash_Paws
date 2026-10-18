import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'backend.dart';

/// Calls a database function (claimDaily -> claim_daily) and shows its error in a snackbar.
Future<Map<String, dynamic>?> callFn(BuildContext c, String name, [Map<String, dynamic>? data]) async {
  final m = ScaffoldMessenger.of(c);
  final fn = name.replaceAllMapped(RegExp('[A-Z]'), (x) => '_${x[0]!.toLowerCase()}');
  try {
    final r = await sb.rpc(fn, params: {'p': data ?? {}});
    return Map<String, dynamic>.from(r as Map);
  } on PostgrestException catch (e) {
    m.showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  }
}
