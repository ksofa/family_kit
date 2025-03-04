class FirstAidKitUser {
  final String userId;
  final String name;
  final String email;
  final String role;
  final bool isCurrentUser;

  FirstAidKitUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.isCurrentUser = false,
  });

  factory FirstAidKitUser.fromJson(Map<String, dynamic> json) {
    return FirstAidKitUser(
      userId: json['user_id'],
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      role: json['role'],
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'is_current_user': isCurrentUser,
    };
  }

  String get roleDescription {
    switch (role) {
      case 'administrator':
        return 'Administrator';
      case 'editor':
        return 'Editor';
      case 'observer':
        return 'Observer';
      default:
        return role;
    }
  }

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
} 