import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import '../widgets/barcode_scanner.dart';
import '../widgets/medicine_search_delegate.dart';

class AddMedicineScreen extends StatefulWidget {
  final String firstAidKitId;

  const AddMedicineScreen({
    Key? key,
    required this.firstAidKitId,
  }) : super(key: key);

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _activeSubstanceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  DateTime _expirationDate = DateTime.now().add(Duration(days: 365));
  bool _isLoading = false;

  Future<void> _selectExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)), // 10 years
    );

    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _addMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final medicine = await MedicineService.createMedicine(
        firstAidKitId: widget.firstAidKitId,
        name: _nameController.text,
        activeSubstance: _activeSubstanceController.text,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
        expirationDate: _expirationDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medicine added successfully')),
      );

      Navigator.pop(context, medicine);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add medicine: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanBarcode() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: BarcodeScanner(
          onBarcodeDetected: (code) {
            Navigator.pop(context, code);
          },
        ),
      ),
    );

    if (barcode != null) {
      setState(() => _isLoading = true);
      try {
        final medicineInfo = await MedicineService.scanBarcode(barcode);
        
        setState(() {
          _nameController.text = medicineInfo['name'] ?? '';
          _activeSubstanceController.text = medicineInfo['active_substance'] ?? '';
          _unitController.text = medicineInfo['unit'] ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medicine information loaded from barcode')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load medicine information: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchMedicine() async {
    final result = await showSearch<Map<String, dynamic>>(
      context: context,
      delegate: MedicineSearchDelegate(),
    );

    if (result != null) {
      setState(() {
        _nameController.text = result['name'] ?? '';
        _activeSubstanceController.text = result['active_substance'] ?? '';
        _unitController.text = result['unit'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _activeSubstanceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medicine'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchMedicine,
            tooltip: 'Search Medicine',
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'Enter medicine name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _activeSubstanceController,
                decoration: InputDecoration(
                  labelText: 'Active Substance',
                  hintText: 'Enter active substance',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter active substance';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        hintText: 'e.g., mg',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter unit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Expiration Date'),
                subtitle: Text(_formatDate(_expirationDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectExpirationDate,
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _addMedicine,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Add Medicine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 