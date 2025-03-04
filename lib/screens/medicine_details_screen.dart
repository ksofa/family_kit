import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import '../widgets/medicine_usage_history.dart';
import '../widgets/record_usage_dialog.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final Medicine medicine;
  final String firstAidKitId;

  const MedicineDetailsScreen({
    Key? key,
    required this.medicine,
    required this.firstAidKitId,
  }) : super(key: key);

  @override
  _MedicineDetailsScreenState createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? _interactions;
  Map<String, dynamic>? _storage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        MedicineService.checkInteractions(widget.medicine.id),
        MedicineService.getStorageRecommendations(widget.medicine.id),
      ]);

      setState(() {
        _interactions = results[0] as List<Map<String, dynamic>>;
        _storage = results[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordUsage() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RecordUsageDialog(
        firstAidKitId: widget.firstAidKitId,
        medicineId: widget.medicine.id,
        unit: widget.medicine.unit,
        maxQuantity: widget.medicine.remainingQuantity,
      ),
    );

    if (result == true) {
      setState(() {}); // Обновляем UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiration = widget.medicine.expirationDate
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 16),
                  if (_interactions != null && _interactions!.isNotEmpty)
                    _buildInteractionsCard(),
                  if (_storage != null) ...[
                    SizedBox(height: 16),
                    _buildStorageCard(),
                  ],
                  SizedBox(height: 16),
                  Text(
                    'История использования',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  MedicineUsageHistory(
                    firstAidKitId: widget.firstAidKitId,
                    medicineId: widget.medicine.id,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recordUsage,
        icon: Icon(Icons.add_chart),
        label: Text('Записать использование'),
      ),
    );
  }

  Widget _buildInfoCard() {
    final daysUntilExpiration = widget.medicine.expirationDate
        .difference(DateTime.now())
        .inDays;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              'Действующее вещество',
              widget.medicine.activeSubstance,
              Icons.science,
            ),
            _buildInfoRow(
              'Осталось',
              '${widget.medicine.remainingQuantity} ${widget.medicine.unit}',
              Icons.inventory,
            ),
            _buildInfoRow(
              'Срок годности',
              '${widget.medicine.expirationDate.day}.${widget.medicine.expirationDate.month}.${widget.medicine.expirationDate.year}',
              Icons.event,
              color: daysUntilExpiration < 30 ? Colors.red : null,
            ),
            if (daysUntilExpiration < 30)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Истекает через $daysUntilExpiration дней!',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Взаимодействия',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ..._interactions!.map((interaction) => ListTile(
              leading: Icon(
                Icons.warning,
                color: interaction['severity'] == 'high'
                    ? Colors.red
                    : Colors.orange,
              ),
              title: Text(interaction['medicine_name']),
              subtitle: Text(interaction['description']),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Условия хранения',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              'Температура',
              '${_storage!['temperature_min']}°C - ${_storage!['temperature_max']}°C',
              Icons.thermostat,
            ),
            _buildInfoRow(
              'Влажность',
              '${_storage!['humidity_min']}% - ${_storage!['humidity_max']}%',
              Icons.water_drop,
            ),
            if (_storage!['special_conditions'] != null)
              _buildInfoRow(
                'Особые условия',
                _storage!['special_conditions'],
                Icons.info,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 8),
          Text(label),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 