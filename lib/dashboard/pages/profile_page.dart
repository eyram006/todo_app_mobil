import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/auth/models/profile.dart';
import 'package:todo_app/auth/services/profile_service.dart';
import 'package:todo_app/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  Profile? _profile;
  bool _loading = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await _profileService.getProfile(userId);
      if (profile != null) {
        setState(() {
          _profile = profile;
          _usernameController.text = profile.username;
          _phoneController.text = profile.phone;
          _countryController.text = profile.country ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement profil: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_profile == null) return;

    final updatedProfile = Profile(
      id: _profile!.id,
      username: _usernameController.text,
      phone: _phoneController.text,
      country: _countryController.text.isEmpty ? null : _countryController.text,
      role: _profile!.role,
    );

    try {
      await _profileService.updateProfile(updatedProfile);
      setState(() => _profile = updatedProfile);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur mise à jour')));
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                _profile?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rôle: ${_profile?.role ?? 'member'}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Pays',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Boutons
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Mettre à jour'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
