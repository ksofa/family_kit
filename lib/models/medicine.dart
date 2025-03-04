class Medicine {
  final String id;
  final String firstAidKitId;
  final String name;
  final String activeSubstance;
  final String form;
  final double remainingQuantity;
  final String unit;
  final DateTime expirationDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? storageInfo;
  final List<Map<String, dynamic>>? interactions;
  final String category;

  Medicine({
    required this.id,
    required this.firstAidKitId,
    required this.name,
    required this.activeSubstance,
    required this.form,
    required this.remainingQuantity,
    required this.unit,
    required this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
    this.storageInfo,
    this.interactions,
    this.category = 'Другое',
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      firstAidKitId: json['first_aid_kit_id'],
      name: json['name'],
      activeSubstance: json['active_substance'],
      form: json['form'],
      remainingQuantity: json['remaining_quantity'].toDouble(),
      unit: json['unit'],
      expirationDate: DateTime.parse(json['expiration_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      storageInfo: json['storage_info'],
      interactions: json['interactions'] != null
          ? List<Map<String, dynamic>>.from(json['interactions'])
          : null,
      category: json['category'] ?? 'Другое',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_aid_kit_id': firstAidKitId,
      'name': name,
      'active_substance': activeSubstance,
      'form': form,
      'remaining_quantity': remainingQuantity,
      'unit': unit,
      'expiration_date': expirationDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (storageInfo != null) 'storage_info': storageInfo,
      if (interactions != null) 'interactions': interactions,
      'category': category,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expirationDate);

  bool get isLowStock => remainingQuantity <= _getLowStockThreshold();

  double _getLowStockThreshold() {
    // Define low stock thresholds based on unit type
    switch (unit.toLowerCase()) {
      case 'tablets':
      case 'pills':
        return 5;
      case 'ml':
      case 'mg':
        return 50;
      default:
        return 1;
    }
  }

  String get quantityDisplay => '$remainingQuantity $unit';

  String get expirationStatus {
    if (isExpired) return 'Expired';
    
    final daysUntilExpiration = expirationDate.difference(DateTime.now()).inDays;
    if (daysUntilExpiration <= 30) {
      return 'Expires in $daysUntilExpiration days';
    }
    return 'Valid until ${_formatDate(expirationDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Medicine copyWith({
    String? name,
    String? activeSubstance,
    String? form,
    double? remainingQuantity,
    String? unit,
    DateTime? expirationDate,
    Map<String, dynamic>? storageInfo,
    List<Map<String, dynamic>>? interactions,
    String? category,
  }) {
    return Medicine(
      id: id,
      firstAidKitId: firstAidKitId,
      name: name ?? this.name,
      activeSubstance: activeSubstance ?? this.activeSubstance,
      form: form ?? this.form,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      storageInfo: storageInfo ?? this.storageInfo,
      interactions: interactions ?? this.interactions,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medicine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstAidKitId == other.firstAidKitId;

  @override
  int get hashCode => id.hashCode ^ firstAidKitId.hashCode;
} 