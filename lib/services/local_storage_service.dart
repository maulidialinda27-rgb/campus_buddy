import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveJsonList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    await init();
    final jsonString = jsonEncode(items);
    await _prefs!.setString(key, jsonString);
  }

  Future<List<Map<String, dynamic>>> loadJsonList(String key) async {
    await init();
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (_) {
      return [];
    }

    return [];
  }

  Future<void> deleteJsonKey(String key) async {
    await init();
    await _prefs!.remove(key);
  }
}
