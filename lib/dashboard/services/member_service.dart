import 'package:supabase_flutter/supabase_flutter.dart';

class MemberService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTeamMembers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, email, full_name, avatar_url, created_at')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur chargement équipe: $e');
    }
  }

  Future<void> addMemberToProject(String projectId, String memberId) async {
    try {
      // Récupérer les membres actuels
      final project = await _supabase
          .from('projects')
          .select('member_ids')
          .eq('id', projectId)
          .single();

      final currentMembers = List<String>.from(project['member_ids'] ?? []);
      if (!currentMembers.contains(memberId)) {
        currentMembers.add(memberId);
        await _supabase
            .from('projects')
            .update({'member_ids': currentMembers})
            .eq('id', projectId);
      }
    } catch (e) {
      throw Exception('Erreur ajout membre: $e');
    }
  }

  Future<void> removeMemberFromProject(
    String projectId,
    String memberId,
  ) async {
    try {
      final project = await _supabase
          .from('projects')
          .select('member_ids')
          .eq('id', projectId)
          .single();

      final currentMembers = List<String>.from(project['member_ids'] ?? []);
      currentMembers.remove(memberId);
      await _supabase
          .from('projects')
          .update({'member_ids': currentMembers})
          .eq('id', projectId);
    } catch (e) {
      throw Exception('Erreur suppression membre: $e');
    }
  }
}
