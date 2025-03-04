class Category {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final List<String> subcategories;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.subcategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      parentId: json['parent_id'],
      subcategories: (json['subcategories'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'parent_id': parentId,
      'subcategories': subcategories,
    };
  }
} 