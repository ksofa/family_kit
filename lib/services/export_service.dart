import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/medicine.dart';
import '../models/first_aid_kit.dart';
import 'medicine_service.dart';

class ExportService {
  static Future<File> exportToPdf(
    FirstAidKit firstAidKit,
    List<Medicine> medicines,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Text(
          'Аптечка: ${firstAidKit.name}',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        build: (context) => [
          pw.Header(
            level: 1,
            child: pw.Text('Список лекарств'),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              ['Название', 'Кол-во', 'Срок годности', 'Категория'],
              ...medicines.map(
                (medicine) => [
                  medicine.name,
                  '${medicine.remainingQuantity} ${medicine.unit}',
                  medicine.expirationDate.toString().split(' ')[0],
                  medicine.category,
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(
            level: 1,
            child: pw.Text('Статистика'),
          ),
          pw.Paragraph(
            text: 'Общее количество лекарств: ${medicines.length}',
          ),
          pw.Paragraph(
            text: 'Истекающие в ближайший месяц: ${_getExpiringCount(medicines)}',
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/аптечка_${firstAidKit.name}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<String> exportToJson(
    FirstAidKit firstAidKit,
    List<Medicine> medicines,
  ) async {
    final data = {
      'first_aid_kit': firstAidKit.toJson(),
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0',
    };

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/аптечка_${firstAidKit.name}.json');
    await file.writeAsString(jsonEncode(data));
    return file.path;
  }

  static Future<Map<String, dynamic>> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      if (data['version'] != '1.0') {
        throw Exception('Неподдерживаемая версия файла');
      }

      return data;
    } catch (e) {
      throw Exception('Ошибка при импорте данных: $e');
    }
  }

  static int _getExpiringCount(List<Medicine> medicines) {
    final oneMonthFromNow = DateTime.now().add(Duration(days: 30));
    return medicines
        .where((m) => m.expirationDate.isBefore(oneMonthFromNow))
        .length;
  }
} 