class NotificationSettings {
  final bool medicineReminders;
  final bool expirationAlerts;
  final bool lowStockAlerts;
  final bool interactionWarnings;
  final bool dailySummary;
  final TimeOfDay? dailySummaryTime;
  final int reminderAdvanceMinutes;

  NotificationSettings({
    this.medicineReminders = true,
    this.expirationAlerts = true,
    this.lowStockAlerts = true,
    this.interactionWarnings = true,
    this.dailySummary = false,
    this.dailySummaryTime,
    this.reminderAdvanceMinutes = 15,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      medicineReminders: json['medicine_reminders'] ?? true,
      expirationAlerts: json['expiration_alerts'] ?? true,
      lowStockAlerts: json['low_stock_alerts'] ?? true,
      interactionWarnings: json['interaction_warnings'] ?? true,
      dailySummary: json['daily_summary'] ?? false,
      dailySummaryTime: json['daily_summary_time'] != null
          ? TimeOfDay(
              hour: json['daily_summary_time']['hour'],
              minute: json['daily_summary_time']['minute'],
            )
          : null,
      reminderAdvanceMinutes: json['reminder_advance_minutes'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_reminders': medicineReminders,
      'expiration_alerts': expirationAlerts,
      'low_stock_alerts': lowStockAlerts,
      'interaction_warnings': interactionWarnings,
      'daily_summary': dailySummary,
      if (dailySummaryTime != null)
        'daily_summary_time': {
          'hour': dailySummaryTime!.hour,
          'minute': dailySummaryTime!.minute,
        },
      'reminder_advance_minutes': reminderAdvanceMinutes,
    };
  }

  NotificationSettings copyWith({
    bool? medicineReminders,
    bool? expirationAlerts,
    bool? lowStockAlerts,
    bool? interactionWarnings,
    bool? dailySummary,
    TimeOfDay? dailySummaryTime,
    int? reminderAdvanceMinutes,
  }) {
    return NotificationSettings(
      medicineReminders: medicineReminders ?? this.medicineReminders,
      expirationAlerts: expirationAlerts ?? this.expirationAlerts,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      interactionWarnings: interactionWarnings ?? this.interactionWarnings,
      dailySummary: dailySummary ?? this.dailySummary,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      reminderAdvanceMinutes: reminderAdvanceMinutes ?? this.reminderAdvanceMinutes,
    );
  }
} 