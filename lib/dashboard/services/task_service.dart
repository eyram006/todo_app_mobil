import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Task>> getTasksByProject(String projectId) async {
    final response = await _supabase
        .from('tasks')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false);

    // Map the response to Task objects
    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<void> createTask(String title, String projectId, String status) async {
    await _supabase.from('tasks').insert({
      'title': title,
      'project_id': projectId,
      'status': 'To Do',
    });
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await _supabase
        .from('tasks')
        .update({'status': newStatus})
        .eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  Future<void> updateTask(Task task) async {
    await _supabase.from('tasks').update(task.toJson()).eq('id', task.id);
  }

  Future<void> addCommentToTask(String taskId, Comment comment) async {
    // Récupérer la tâche actuelle
    final response = await _supabase
        .from('tasks')
        .select('comments')
        .eq('id', taskId)
        .single();

    final currentComments =
        (response['comments'] as List<dynamic>?)
            ?.map((e) => Comment.fromJson(e))
            .toList() ??
        [];

    // Ajouter le nouveau commentaire
    currentComments.add(comment);

    // Mettre à jour la tâche
    await _supabase
        .from('tasks')
        .update({'comments': currentComments.map((c) => c.toJson()).toList()})
        .eq('id', taskId);
  }

  Future<void> updateTaskAttachments(
    String taskId,
    List<String> attachments,
  ) async {
    await _supabase
        .from('tasks')
        .update({'attachments': attachments})
        .eq('id', taskId);
  }

  Future<void> updateTaskSubTasks(String taskId, List<SubTask> subTasks) async {
    await _supabase
        .from('tasks')
        .update({'sub_tasks': subTasks.map((st) => st.toJson()).toList()})
        .eq('id', taskId);
  }
}
