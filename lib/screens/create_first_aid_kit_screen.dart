import 'package:flutter/material.dart';
import '../models/first_aid_kit.dart';
import '../services/first_aid_kit_service.dart';

class CreateFirstAidKitScreen extends StatefulWidget {
  @override
  _CreateFirstAidKitScreenState createState() => _CreateFirstAidKitScreenState();
}

class _CreateFirstAidKitScreenState extends State<CreateFirstAidKitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createFirstAidKit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final firstAidKit = await FirstAidKitService.createFirstAidKit(
        name: _nameController.text,
        description: _descriptionController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('First aid kit created successfully')),
      );

      Navigator.pop(context, firstAidKit);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create first aid kit: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create First Aid Kit'),
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
                  labelText: 'Name',
                  hintText: 'Enter a name for your first aid kit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a description for your first aid kit',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createFirstAidKit,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Create First Aid Kit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 