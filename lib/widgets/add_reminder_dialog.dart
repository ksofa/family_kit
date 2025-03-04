import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class AddReminderDialog extends StatefulWidget {
  final String medicineId;

  const AddReminderDialog({
    Key? key,
    required this.medicineId,
  }) : super(key: key);

  @override
  _AddReminderDialogState createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  late TimeOfDay _selectedTime;
  String _selectedFrequency = 'Once daily';
  int _durationDays = 7;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createReminder() async {
    try {
      setState(() => _isLoading = true);

      final now = DateTime.now();
      final time = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final reminder = await ReminderService.createReminder(
        medicineId: widget.medicineId,
        time: time,
        frequency: _selectedFrequency,
        durationDays: _durationDays,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Navigator.of(context).pop(reminder);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create reminder: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Time'),
              trailing: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: InputDecoration(labelText: 'Frequency'),
              items: ReminderService.getFrequencyOptions()
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFrequency = value);
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Duration (days)',
                suffixText: 'days',
              ),
              keyboardType: TextInputType.number,
              initialValue: _durationDays.toString(),
              onChanged: (value) {
                setState(() => _durationDays = int.tryParse(value) ?? 7);
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any additional notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createReminder,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Create'),
        ),
      ],
    );
  }
} 