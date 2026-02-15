import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/models/statistics.dart';

class StatisticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Statistics> getUserStatistics(String userId) async {
    try {
      // Statistiques des projets
      final projectsResponse = await _supabase
          .from('projects')
          .select('id, member_ids')
          .contains('member_ids', [userId]);

      final totalProjects = projectsResponse.length;
      final projectIds = projectsResponse
          .map((p) => p['id'] as String)
          .toList();

      // Statistiques des tâches
      final tasksResponse = await _supabase
          .from('tasks')
          .select('status, project_id')
          .filter(
            'project_id',
            'in',
            '(${projectIds.map((id) => '"$id"').join(',')})',
          );

      final totalTasks = tasksResponse.length;
      final completedTasks = tasksResponse
          .where((t) => t['status'] == 'completed')
          .length;
      final pendingTasks = tasksResponse
          .where((t) => t['status'] == 'pending')
          .length;
      final inProgressTasks = tasksResponse
          .where((t) => t['status'] == 'in_progress')
          .length;

      final completionRate = totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0;

      // Tâches par statut
      final tasksByStatus = {
        'pending': pendingTasks,
        'in_progress': inProgressTasks,
        'completed': completedTasks,
      };

      // Membres totaux et actifs
      final allMemberIds = <String>{};
      for (final project in projectsResponse) {
        final memberIds = List<String>.from(project['member_ids'] ?? []);
        allMemberIds.addAll(memberIds);
      }

      final totalMembers = allMemberIds.length;

      // Membres actifs (ceux qui ont créé ou modifié des tâches récemment)
      final activeMembersResponse = await _supabase
          .from('tasks')
          .select('created_by')
          .filter(
            'project_id',
            'in',
            '(${projectIds.map((id) => '"$id"').join(',')})',
          )
          .gte(
            'updated_at',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          );

      final activeMemberIds = <String>{};
      for (final task in activeMembersResponse) {
        activeMemberIds.add(task['created_by'] as String);
      }

      final activeMembers = activeMemberIds.length;

      // Projets par mois (simulation - en vrai, faudrait une vraie aggrégation)
      final projectsByMonth = <String, int>{
        'Jan': 2,
        'Fév': 1,
        'Mar': 3,
        'Avr': 2,
        'Mai': 4,
        'Jun': 1,
      };

      return Statistics(
        totalProjects: totalProjects,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        inProgressTasks: inProgressTasks,
        completionRate: completionRate,
        tasksByStatus: tasksByStatus,
        projectsByMonth: projectsByMonth,
        totalMembers: totalMembers,
        activeMembers: activeMembers,
      );
    } catch (e) {
      throw Exception('Erreur chargement statistiques: $e');
    }
  }

  Future<Map<String, dynamic>> getProductivityData(
    String userId,
    int days,
  ) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      // Tâches complétées par jour
      final completedTasksResponse = await _supabase
          .from('tasks')
          .select('completed_at')
          .eq('created_by', userId)
          .eq('status', 'completed')
          .gte('completed_at', startDate.toIso8601String())
          .order('completed_at');

      final tasksByDay = <String, int>{};
      for (final task in completedTasksResponse) {
        final date = DateTime.parse(task['completed_at'] as String);
        final dayKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        tasksByDay[dayKey] = (tasksByDay[dayKey] ?? 0) + 1;
      }

      return {
        'tasks_completed_by_day': tasksByDay,
        'total_completed': completedTasksResponse.length,
        'average_per_day': completedTasksResponse.length / days,
      };
    } catch (e) {
      throw Exception('Erreur chargement données productivité: $e');
    }
  }
}
