import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;

  const ReminderCard({
    Key? key,
    required this.reminder,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.medicineName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 8),
                Text(reminder.timeString),
                SizedBox(width: 16),
                Icon(Icons.repeat, size: 16),
                SizedBox(width: 8),
                Text(ReminderService.getFrequencyDescription(reminder.frequency)),
              ],
            ),
            if (reminder.notes != null) ...[
              SizedBox(height: 8),
              Text(
                reminder.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Until ${_formatDate(reminder.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    if (!reminder.isActive) {
      color = Colors.grey;
    } else if (reminder.isExpired) {
      color = Colors.red;
    } else {
      color = Colors.green;
    }

    return Chip(
      label: Text(
        reminder.statusText,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 