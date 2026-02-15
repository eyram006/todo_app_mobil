class Profile {
  final String id;
  final String username;
  final String phone;
  final String? country;
  final String role; // admin, manager, member

  Profile({
    required this.id,
    required this.username,
    required this.phone,
    this.country,
    this.role = 'member', // default role
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      phone: json['phone'],
      country: json['country'],
      role: json['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'country': country,
      'role': role,
    };
  }
}
