class Reminder {
  final String id;
  final String medicineId;
  final String medicineName;
  final String userId;
  final DateTime time;
  final String frequency;
  final int durationDays;
  final String? notes;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.userId,
    required this.time,
    required this.frequency,
    required this.durationDays,
    this.notes,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      medicineId: json['medicine_id'],
      medicineName: json['medicine_name'],
      userId: json['user_id'],
      time: DateTime.parse(json['time']),
      frequency: json['frequency'],
      durationDays: json['duration_days'],
      notes: json['notes'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'time': time.toIso8601String(),
      'frequency': frequency,
      'duration_days': durationDays,
      'notes': notes,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  
  String get timeString => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  
  String get statusText => isActive 
      ? (isExpired ? 'Expired' : 'Active') 
      : 'Inactive';
} 