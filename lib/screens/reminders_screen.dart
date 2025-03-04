import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../widgets/reminder_card.dart';
import '../widgets/add_reminder_dialog.dart';

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      setState(() => _isLoading = true);
      final reminders = await ReminderService.getUserReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reminders: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addReminder(String medicineId) async {
    final reminder = await showDialog<Reminder>(
      context: context,
      builder: (context) => AddReminderDialog(medicineId: medicineId),
    );

    if (reminder != null) {
      setState(() => _reminders.add(reminder));
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    try {
      await ReminderService.deleteReminder(reminder.id);
      setState(() {
        _reminders.removeWhere((r) => r.id == reminder.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_reminders.isEmpty) {
      return Center(
        child: Text('No reminders set'),
      );
    }

    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return ReminderCard(
          reminder: reminder,
          onDelete: () => _deleteReminder(reminder),
        );
      },
    );
  }
} 