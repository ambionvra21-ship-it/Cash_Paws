import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get sb => Supabase.instance.client;

/// Live stream of the signed-in player's profile row, with camelCase keys.
Stream<Map<String, dynamic>> profileStream() => sb
    .from('profiles')
    .stream(primaryKey: ['id'])
    .eq('id', sb.auth.currentUser!.id)
    .map((rows) {
  if (rows.isEmpty) return <String, dynamic>{};
  final r = rows.first;
  final m = <String, dynamic>{};
  r.forEach((k, v) => m[k.replaceAllMapped(RegExp('_([a-z])'), (x) => x[1]!.toUpperCase())] = v);
  m['last'] = r['last_claim'];
  m['freeze'] = r['streak_freeze'];
  return m;
});
