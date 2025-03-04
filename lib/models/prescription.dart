class Prescription {
  final String id;
  final String medicineId;
  final String userId;
  final double dosage;
  final String unit;
  final String frequency;
  final int courseDuration;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.medicineId,
    required this.userId,
    required this.dosage,
    required this.unit,
    required this.frequency,
    required this.courseDuration,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      medicineId: json['medicine_id'],
      userId: json['user_id'],
      dosage: json['dosage'].toDouble(),
      unit: json['unit'],
      frequency: json['frequency'],
      courseDuration: json['course_duration'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'user_id': userId,
      'dosage': dosage,
      'unit': unit,
      'frequency': frequency,
      'course_duration': courseDuration,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
    };
  }
} 