import 'package:flutter/material.dart';
import '../services/access_control_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class AuditLogScreen extends StatefulWidget {
  final String firstAidKitId;

  const AuditLogScreen({
    Key? key,
    required this.firstAidKitId,
  }) : super(key: key);

  @override
  _AuditLogScreenState createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await AccessControlService.getAuditLog(widget.firstAidKitId);
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки логов: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История действий'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: _getActionIcon(log['action']),
                    title: Text(log['action']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log['user_name'] ?? 'Unknown user'),
                        Text(
                          timeago.format(
                            DateTime.parse(log['timestamp']),
                            locale: 'ru',
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () => _showDetails(log),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Icon _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'add':
        return Icon(Icons.add_circle, color: Colors.green);
      case 'edit':
        return Icon(Icons.edit, color: Colors.blue);
      case 'delete':
        return Icon(Icons.delete, color: Colors.red);
      case 'view':
        return Icon(Icons.visibility);
      default:
        return Icon(Icons.info);
    }
  }

  void _showDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подробности'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Действие: ${log['action']}'),
              Text('Пользователь: ${log['user_name']}'),
              Text('Время: ${log['timestamp']}'),
              if (log['details'] != null) ...[
                Divider(),
                Text('Детали:'),
                Text(
                  log['details'].toString(),
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }
} 