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
}
