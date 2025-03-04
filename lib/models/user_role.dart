class UserRole {
  final String userId;
  final String role;
  final List<String> permissions;

  UserRole({
    required this.userId,
    required this.role,
    required this.permissions,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      userId: json['user_id'],
      role: json['role'],
      permissions: List<String>.from(json['permissions']),
    );
  }

  bool can(String permission) => permissions.contains(permission);

  static const String VIEW_MEDICINES = 'view_medicines';
  static const String ADD_MEDICINES = 'add_medicines';
  static const String EDIT_MEDICINES = 'edit_medicines';
  static const String DELETE_MEDICINES = 'delete_medicines';
  static const String MANAGE_USERS = 'manage_users';
  static const String VIEW_AUDIT_LOG = 'view_audit_log';
  static const String EXPORT_DATA = 'export_data';
} 