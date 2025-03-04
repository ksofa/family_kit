import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class ScannerService {
  static Future<Map<String, dynamic>> scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcode == '-1') {
        throw Exception('Scanning cancelled');
      }

      // Send barcode to backend
      final response = await ApiService.get('/medicines/scan/barcode/$barcode');
      return response;
    } on PlatformException {
      throw Exception('Failed to scan barcode');
    }
  }

  static Future<Map<String, dynamic>> scanQRCode() async {
    try {
      String qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (qrCode == '-1') {
        throw Exception('Scanning cancelled');
      }

      // Parse QR code data
      Map<String, dynamic> qrData = json.decode(qrCode);

      // Send QR data to backend
      final response = await ApiService.post('/medicines/scan/qr', qrData);
      return response;
    } on PlatformException {
      throw Exception('Failed to scan QR code');
    } on FormatException {
      throw Exception('Invalid QR code format');
    }
  }
} 