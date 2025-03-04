import 'package:flutter/material.dart';
import '../services/statistics_service.dart';

class RecordUsageDialog extends StatefulWidget {
  final String firstAidKitId;
  final String medicineId;
  final String unit;
  final double maxQuantity;

  const RecordUsageDialog({
    Key? key,
    required this.firstAidKitId,
    required this.medicineId,
    required this.unit,
    required this.maxQuantity,
  }) : super(key: key);

  @override
  _RecordUsageDialogState createState() => _RecordUsageDialogState();
}

class _RecordUsageDialogState extends State<RecordUsageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _recordUsage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final quantity = double.parse(_quantityController.text);
      await StatisticsService.recordMedicineUsage(
        widget.firstAidKitId,
        widget.medicineId,
        quantity,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось записать использование: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Записать использование'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _quantityController,
          decoration: InputDecoration(
            labelText: 'Количество',
            suffixText: widget.unit,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите количество';
            }
            final quantity = double.tryParse(value);
            if (quantity == null) {
              return 'Введите корректное число';
            }
            if (quantity <= 0) {
              return 'Количество должно быть больше 0';
            }
            if (quantity > widget.maxQuantity) {
              return 'Превышает доступное количество';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _recordUsage,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Записать'),
        ),
      ],
    );
  }
} 