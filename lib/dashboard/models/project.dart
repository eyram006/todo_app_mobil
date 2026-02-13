class Project {
  final String id;
  final String name;
  final String? description;
  final String status; // todo | in_progress | done
  final DateTime? deadline;
  final String ownerId;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.deadline,
    required this.ownerId,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      ownerId: json['owner_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'deadline': deadline?.toIso8601String(),
      'owner_id': ownerId,
    };
  }
}
