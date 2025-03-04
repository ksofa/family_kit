import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfService {
  static Future<void> downloadAndSharePdf(String url) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'medicine_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';

      // Download file
      final response = await http.get(Uri.parse(url));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Share file
      await Share.shareFiles([filePath], text: 'Medicine Report');
    } catch (e) {
      throw Exception('Failed to download and share PDF: $e');
    }
  }

  static Future<void> openPdfUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      throw Exception('Failed to open PDF: $e');
    }
  }
} 