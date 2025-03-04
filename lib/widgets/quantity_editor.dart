import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityEditor extends StatefulWidget {
  final double initialQuantity;
  final String unit;
  final Function(double) onUpdate;

  const QuantityEditor({
    Key? key,
    required this.initialQuantity,
    required this.unit,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _QuantityEditorState createState() => _QuantityEditorState();
}

class _QuantityEditorState extends State<QuantityEditor> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateQuantity() async {
    final newQuantity = double.tryParse(_controller.text);
    if (newQuantity == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.onUpdate(newQuantity);
      Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Update Quantity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    suffixText: widget.unit,
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateQuantity,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Update'),
          ),
        ],
      ),
    );
  }
} 