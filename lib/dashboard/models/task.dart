class Task {
  final String id;
  final String projectId;
  final String title;
  final String status; // todo | in_progress | done
  final String? assignedTo;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    this.assignedTo,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['project_id'],
      title: json['title'],
      status: json['status'],
      assignedTo: json['assigned_to'],
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'status': status,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}
