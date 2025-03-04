import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../config/api_config.dart';

class ApiService {
  static final _functions = FirebaseFunctions.instance;

  static Future<dynamic> callFunction(String name, [Map<String, dynamic>? data]) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(data ?? {});
      return result.data;
    } catch (e) {
      throw Exception('Failed to call function $name: $e');
    }
  }

  static Future<dynamic> get(String path) async {
    return callFunction('get${path.split('/').last}');
  }

  static Future<dynamic> post(String path, Map<String, dynamic> data) async {
    return callFunction('create${path.split('/').last}', data);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> data) async {
    return callFunction('update${path.split('/').last}', data);
  }

  static Future<dynamic> delete(String path) async {
    return callFunction('delete${path.split('/').last}');
  }
} 