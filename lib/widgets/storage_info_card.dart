import 'package:flutter/material.dart';

class StorageInfoCard extends StatelessWidget {
  final Map<String, dynamic> storageInfo;

  const StorageInfoCard({
    Key? key,
    required this.storageInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage),
                SizedBox(width: 8),
                Text(
                  'Storage Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (storageInfo['temperature'] != null) ...[
              _buildStorageItem(
                context,
                Icons.thermostat,
                'Temperature',
                '${storageInfo['temperature']}°C',
              ),
              SizedBox(height: 8),
            ],
            if (storageInfo['humidity'] != null) ...[
              _buildStorageItem(
                context,
                Icons.water_drop,
                'Humidity',
                '${storageInfo['humidity']}%',
              ),
              SizedBox(height: 8),
            ],
            if (storageInfo['light'] != null) ...[
              _buildStorageItem(
                context,
                Icons.light_mode,
                'Light',
                storageInfo['light'],
              ),
              SizedBox(height: 8),
            ],
            if (storageInfo['special_instructions'] != null) ...[
              _buildStorageItem(
                context,
                Icons.info_outline,
                'Special Instructions',
                storageInfo['special_instructions'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorageItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 