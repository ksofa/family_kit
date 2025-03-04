import 'package:flutter/material.dart';

class InteractionWarningCard extends StatelessWidget {
  final Map<String, dynamic> warning;

  const InteractionWarningCard({
    Key? key,
    required this.warning,
  }) : super(key: key);

  Color _getSeverityColor() {
    switch (warning['severity']?.toLowerCase()) {
      case 'high':
        return Colors.red[100]!;
      case 'medium':
        return Colors.orange[100]!;
      case 'low':
        return Colors.yellow[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  IconData _getSeverityIcon() {
    switch (warning['severity']?.toLowerCase()) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.warning_amber;
      case 'low':
        return Icons.info_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getSeverityColor(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSeverityIcon()),
                SizedBox(width: 8),
                Text(
                  warning['interacting_medicine'] ?? 'Unknown Medicine',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(warning['description'] ?? ''),
            if (warning['recommendation'] != null) ...[
              SizedBox(height: 8),
              Text(
                warning['recommendation']!,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 