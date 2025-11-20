import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://dfxxawdxzlzfkaizbdli.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmeHhhd2R4emx6ZmthaXpiZGxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1ODM3NDcsImV4cCI6MjA3MjE1OTc0N30.il76cDOXVpl34jQf974LVJTojqPRq2kkPIK0PftfXlw';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static User? get currentUser => client.auth.currentUser;
  
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}