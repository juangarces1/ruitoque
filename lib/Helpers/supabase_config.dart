import 'package:ruitoque/Helpers/backend_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration for the OpenGolf backend.
/// The backend is self-hosted (Postgres + PostgREST; only /rest/v1/rpc is
/// served). Its URL and key live in backend_local.dart, which is not in git:
/// copy backend_local.example.dart to create it.
/// The legacy .NET API was replaced by Supabase RPC functions that
/// return the exact JSON shapes the app models already expect.
class SupabaseConfig {
  static const String url = backendUrl;
  static const String publishableKey = backendKey;

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

/// Shorthand accessor for the Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
