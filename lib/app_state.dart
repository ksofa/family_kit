import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  List<String> _medkitlist = [];
  List<String> get medkitlist => _medkitlist;
  set medkitlist(List<String> value) {
    _medkitlist = value;
  }

  void addToMedkitlist(String value) {
    medkitlist.add(value);
  }

  void removeFromMedkitlist(String value) {
    medkitlist.remove(value);
  }

  void removeAtIndexFromMedkitlist(int index) {
    medkitlist.removeAt(index);
  }

  void updateMedkitlistAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    medkitlist[index] = updateFn(_medkitlist[index]);
  }

  void insertAtIndexInMedkitlist(int index, String value) {
    medkitlist.insert(index, value);
  }
}
