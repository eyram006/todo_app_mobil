class Task {
  final String id;
  final String projectId;
  final String title;
  final String status; // To Do | In Progress | Done
  final String? assignedTo;
  final DateTime? dueDate;
  final List<SubTask> subTasks;
  final List<Comment> comments;
  final List<String> attachments; // URLs des fichiers

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    this.assignedTo,
    this.dueDate,
    this.subTasks = const [],
    this.comments = const [],
    this.attachments = const [],
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
      subTasks:
          (json['sub_tasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e))
              .toList() ??
          [],
      attachments: List<String>.from(json['attachments'] ?? []),
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
      'sub_tasks': subTasks.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'attachments': attachments,
    };
  }

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
    List<SubTask>? subTasks,
    List<Comment>? comments,
    List<String>? attachments,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      subTasks: subTasks ?? this.subTasks,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
    );
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({required this.id, required this.title, this.isCompleted = false});

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'is_completed': isCompleted};
  }
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
