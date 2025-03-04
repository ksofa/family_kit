class FirstAidKit {
  final String id;
  final String name;
  final String description;
  final List<Map<String, dynamic>> users;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirstAidKit({
    required this.id,
    required this.name,
    required this.description,
    required this.users,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirstAidKit.fromJson(Map<String, dynamic> json) {
    return FirstAidKit(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      users: List<Map<String, dynamic>>.from(json['users'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  bool get isShared => users.length > 1;

  String get userCount => '${users.length} ${users.length == 1 ? 'user' : 'users'}';

  String get lastUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 30) {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class FirstAidKitUser {
  final String userId;
  final String role;

  FirstAidKitUser({
    required this.userId,
    required this.role,
  });

  factory FirstAidKitUser.fromJson(Map<String, dynamic> json) {
    return FirstAidKitUser(
      userId: json['user_id'],
      role: json['role'],
    );
  }
} 