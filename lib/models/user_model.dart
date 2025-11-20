class UserModel {
  final int id;
  final String? name;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCustomer => role == 'customer';
  bool get isStaff => role == 'staff';
  bool get isManager => role == 'manager';
  bool get isOwner => role == 'owner';
}