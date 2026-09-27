import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration for the OpenGolf backend.
/// The legacy .NET API was replaced by Supabase RPC functions that
/// return the exact JSON shapes the app models already expect.
class SupabaseConfig {
  static const String url = 'https://xsxxfkkhpomprnlmsyyr.supabase.co';
  static const String publishableKey = 'sb_publishable_AkcSXd_U_cXf97wqdY-J-w_AJKhy2aA';

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

/// Shorthand accessor for the Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
