class Project {
  final String id;
  final String name;
  final String? description;
  final String status; // todo | in_progress | done
  final DateTime? deadline;
  final String ownerId;
  final List<String> memberIds; // IDs des membres

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.deadline,
    required this.ownerId,
    this.memberIds = const [],
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
      memberIds: List<String>.from(json['member_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'status': status,
      'deadline': deadline?.toIso8601String(),
      'owner_id': ownerId,
      'member_ids': memberIds,
    };

    // If an ID was provided (e.g. for updates), include it.
    // For new records, keep it out so the database can generate a UUID.
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }
}
