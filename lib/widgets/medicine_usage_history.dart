import 'package:flutter/material.dart';
import '../services/statistics_service.dart';

class MedicineUsageHistory extends StatefulWidget {
  final String firstAidKitId;
  final String medicineId;

  const MedicineUsageHistory({
    Key? key,
    required this.firstAidKitId,
    required this.medicineId,
  }) : super(key: key);

  @override
  _MedicineUsageHistoryState createState() => _MedicineUsageHistoryState();
}

class _MedicineUsageHistoryState extends State<MedicineUsageHistory> {
  List<Map<String, dynamic>>? _usageHistory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsageHistory();
  }

  Future<void> _loadUsageHistory() async {
    try {
      final history = await StatisticsService.getMedicineUsageHistory(
        widget.firstAidKitId,
        widget.medicineId,
      );
      setState(() {
        _usageHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить историю: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _usageHistory == null
            ? Center(child: Text('Не удалось загрузить историю'))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _usageHistory!.length,
                itemBuilder: (context, index) {
                  final usage = _usageHistory![index];
                  return ListTile(
                    leading: Icon(Icons.history),
                    title: Text(
                      'Использовано: ${usage['quantity']} ${usage['unit']}',
                    ),
                    subtitle: Text(usage['date']),
                    trailing: Text(
                      'Осталось: ${usage['remaining']} ${usage['unit']}',
                    ),
                  );
                },
              );
  }
} 