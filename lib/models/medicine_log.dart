class MedicineLog {
  final String id;
  final String medicineId;
  final String userId;
  final double dosage;
  final String unit;
  final String status;
  final String? notes;
  final DateTime date;
  final DateTime time;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineLog({
    required this.id,
    required this.medicineId,
    required this.userId,
    required this.dosage,
    required this.unit,
    required this.status,
    this.notes,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      id: json['id'],
      medicineId: json['medicine_id'],
      userId: json['user_id'],
      dosage: json['dosage'].toDouble(),
      unit: json['unit'],
      status: json['status'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      time: DateTime.parse(json['time']),
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
      'status': status,
      'notes': notes,
    };
  }
} 