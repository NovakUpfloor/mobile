// lib/models/user_model.dart

class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_user'] ?? 0,
      name: json['nama'] ?? 'Guest',
      email: json['email'] ?? '',
      role: json['akses_level'] ?? 'User',
    );
  }
}
