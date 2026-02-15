import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return Profile.fromJson(response);
  }

  Future<void> updateProfile(Profile profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  Future<List<Profile>> getAllProfiles() async {
    final response = await _supabase.from('profiles').select();
    return (response as List).map((json) => Profile.fromJson(json)).toList();
  }
}
