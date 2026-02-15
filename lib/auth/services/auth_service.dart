import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String? country,
    String role = 'member',
  }) async {
    // 1️⃣ Création utilisateur auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception("Erreur lors de la création du compte");
    }

    // 2️⃣ Création profil
    final profile = Profile(
      id: user.id,
      username: username,
      phone: phone,
      country: country,
      role: role,
    );

    await _supabase.from('profiles').insert(profile.toJson());
  }

  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
