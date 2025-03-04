import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import '../services/notification_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _expirationAlerts = true;
  bool _lowStockAlerts = true;
  bool _medicineReminders = true;
  int _expirationDays = 30;
  double _lowStockThreshold = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _expirationAlerts = prefs.getBool('expiration_alerts') ?? true;
      _lowStockAlerts = prefs.getBool('low_stock_alerts') ?? true;
      _medicineReminders = prefs.getBool('medicine_reminders') ?? true;
      _expirationDays = prefs.getInt('expiration_days') ?? 30;
      _lowStockThreshold = prefs.getDouble('low_stock_threshold') ?? 5;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('expiration_alerts', _expirationAlerts);
    await prefs.setBool('low_stock_alerts', _lowStockAlerts);
    await prefs.setBool('medicine_reminders', _medicineReminders);
    await prefs.setInt('expiration_days', _expirationDays);
    await prefs.setDouble('low_stock_threshold', _lowStockThreshold);

    if (!_medicineReminders) {
      await NotificationManager.cancelAllNotifications();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Настройки сохранены')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки уведомлений'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: 'Общие настройки',
                  children: [
                    SwitchListTile(
                      title: Text('Напоминания о приеме'),
                      subtitle: Text('Уведомления о времени приема лекарств'),
                      value: _medicineReminders,
                      onChanged: (value) {
                        setState(() => _medicineReminders = value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('Уведомления об истечении срока годности'),
                      subtitle: Text('Предупреждения о скором истечении срока годности'),
                      value: _expirationAlerts,
                      onChanged: (value) {
                        setState(() => _expirationAlerts = value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('Уведомления о низком запасе'),
                      subtitle: Text('Предупреждения о заканчивающихся лекарствах'),
                      value: _lowStockAlerts,
                      onChanged: (value) {
                        setState(() => _lowStockAlerts = value);
                      },
                    ),
                  ],
                ),
                if (_expirationAlerts) ...[
                  SizedBox(height: 16),
                  _buildSection(
                    title: 'Настройки срока годности',
                    children: [
                      ListTile(
                        title: Text('За сколько дней предупреждать'),
                        subtitle: Slider(
                          value: _expirationDays.toDouble(),
                          min: 7,
                          max: 90,
                          divisions: 83,
                          label: '$_expirationDays дней',
                          onChanged: (value) {
                            setState(() => _expirationDays = value.round());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                if (_lowStockAlerts) ...[
                  SizedBox(height: 16),
                  _buildSection(
                    title: 'Настройки запаса',
                    children: [
                      ListTile(
                        title: Text('Порог для уведомления'),
                        subtitle: Slider(
                          value: _lowStockThreshold,
                          min: 1,
                          max: 20,
                          divisions: 19,
                          label: '$_lowStockThreshold',
                          onChanged: (value) {
                            setState(() => _lowStockThreshold = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: Text('Сохранить настройки'),
                ),
                SizedBox(height: 16),
                if (_medicineReminders)
                  OutlinedButton(
                    onPressed: () async {
                      await NotificationManager.cancelAllNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Все уведомления отменены')),
                      );
                    },
                    child: Text('Отменить все уведомления'),
                  ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
} 