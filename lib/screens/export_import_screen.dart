import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/first_aid_kit.dart';
import '../models/medicine.dart';
import '../services/export_service.dart';
import '../services/medicine_service.dart';

class ExportImportScreen extends StatefulWidget {
  final FirstAidKit firstAidKit;
  final List<Medicine> medicines;

  const ExportImportScreen({
    Key? key,
    required this.firstAidKit,
    required this.medicines,
  }) : super(key: key);

  @override
  _ExportImportScreenState createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  bool _isLoading = false;

  Future<void> _exportToPdf() async {
    setState(() => _isLoading = true);
    try {
      final file = await ExportService.exportToPdf(
        widget.firstAidKit,
        widget.medicines,
      );
      await Share.shareFiles(
        [file.path],
        text: 'Экспорт аптечки ${widget.firstAidKit.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при экспорте: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToJson() async {
    setState(() => _isLoading = true);
    try {
      final filePath = await ExportService.exportToJson(
        widget.firstAidKit,
        widget.medicines,
      );
      await Share.shareFiles(
        [filePath],
        text: 'Резервная копия аптечки ${widget.firstAidKit.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при экспорте: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromJson() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final data = await ExportService.importFromJson(result.files.single.path!);
        // Обработка импортированных данных
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Данные успешно импортированы')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при импорте: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Экспорт/Импорт'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: 'Экспорт',
                  children: [
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Экспорт в PDF'),
                      subtitle: Text('Создать отчет в формате PDF'),
                      onTap: _exportToPdf,
                    ),
                    ListTile(
                      leading: Icon(Icons.backup),
                      title: Text('Резервная копия'),
                      subtitle: Text('Экспорт всех данных в JSON'),
                      onTap: _exportToJson,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildSection(
                  title: 'Импорт',
                  children: [
                    ListTile(
                      leading: Icon(Icons.restore),
                      title: Text('Восстановить из файла'),
                      subtitle: Text('Импорт данных из JSON'),
                      onTap: _importFromJson,
                    ),
                  ],
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