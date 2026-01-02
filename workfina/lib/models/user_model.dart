

class User {
  final String id;
  final String email;
  final String username;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}