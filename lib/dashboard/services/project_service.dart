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

  Future<Project> getProject(String projectId) async {
    // Utilise .single() pour s'attendre à un seul enregistrement
    // Si aucun enregistrement n'est trouvé, Supabase lancera une erreur.
    final response = await _supabase
        .from('projects')
        .select()
        .eq('id', projectId)
        .single(); // Récupère un seul objet JSON

    return Project.fromJson(response);
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
