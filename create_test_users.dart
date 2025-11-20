import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dfxxawdxzlzfkaizbdli.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmeHhhd2R4emx6ZmthaXpiZGxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1ODM3NDcsImV4cCI6MjA3MjE1OTc0N30.il76cDOXVpl34jQf974LVJTojqPRq2kkPIK0PftfXlw',
  );

  final client = Supabase.instance.client;

  try {
    // Create owner account
    print('Creating owner account...');
    final authResponse = await client.auth.signUp(
      email: 'owner@test.com',
      password: 'password123',
    );

    if (authResponse.user != null) {
      final userResponse = await client
          .from('users')
          .insert({
            'email': 'owner@test.com',
            'name': 'Business Owner',
            'role': 'owner',
          })
          .select()
          .single();

      print('Owner account created successfully!');
      print('Email: owner@test.com');
      print('Password: password123');
    }

    // Create staff account
    print('Creating staff account...');
    final staffAuthResponse = await client.auth.signUp(
      email: 'staff@test.com',
      password: 'password123',
    );

    if (staffAuthResponse.user != null) {
      final staffUserResponse = await client
          .from('users')
          .insert({
            'email': 'staff@test.com',
            'name': 'Staff Member',
            'role': 'staff',
          })
          .select()
          .single();

      // Create staff record
      await client
          .from('staff')
          .insert({
            'user_id': staffUserResponse['id'],
            'role': 'staff',
            'location_id': 1,
          });

      print('Staff account created successfully!');
      print('Email: staff@test.com');
      print('Password: password123');
    }

  } catch (e) {
    print('Error creating accounts: $e');
  }
}