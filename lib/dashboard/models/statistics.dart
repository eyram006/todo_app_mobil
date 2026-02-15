class Statistics {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final double completionRate;
  final Map<String, int> tasksByStatus;
  final Map<String, int> projectsByMonth;
  final int totalMembers;
  final int activeMembers;

  Statistics({
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.completionRate,
    required this.tasksByStatus,
    required this.projectsByMonth,
    required this.totalMembers,
    required this.activeMembers,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalProjects: json['total_projects'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      inProgressTasks: json['in_progress_tasks'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      tasksByStatus: Map<String, int>.from(json['tasks_by_status'] ?? {}),
      projectsByMonth: Map<String, int>.from(json['projects_by_month'] ?? {}),
      totalMembers: json['total_members'] ?? 0,
      activeMembers: json['active_members'] ?? 0,
    );
  }
}
