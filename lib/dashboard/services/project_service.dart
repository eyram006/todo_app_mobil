import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class ProjectService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Project>> getUserProjects(String userId) async {
    final response = await _supabase
        .from('projects')
        .select()
        .eq('owner_id', userId);

    return (response as List)
        .map((json) => Project.fromJson(json))
        .toList();
  }

  Future<void> createProject(Project project) async {
    await _supabase
        .from('projects')
        .insert(project.toJson());
  }

  Future<void> deleteProject(String projectId) async {
    await _supabase
        .from('projects')
        .delete()
        .eq('id', projectId);
  }
}
