import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// A cache access provider class for shared preferences using Hive library
class HiveCache extends CacheProvider {
  late Box _preferences;
  static const String keyName = 'app_settings';

  @override
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb) {
      final Directory defaultDirectory =
          await getApplicationDocumentsDirectory();
      Hive.init(defaultDirectory.path);
    }
    if (Hive.isBoxOpen(keyName)) {
      _preferences = Hive.box(keyName);
    } else {
      _preferences = await Hive.openBox(keyName);
    }
  }

  Set get keys => getKeys();

//dart double? getBool(String key, {bool? defaultValue}) { return _preferences.getBool(key) ?? defaultValue; }
  @override
  bool getBool(String key, {bool? defaultValue}) {
    return _preferences.get(key) ?? defaultValue;
  }

  @override
  double getDouble(String key, {double? defaultValue}) {
    return _preferences.get(key) ?? defaultValue;
  }

  @override
  int getInt(String key, {int? defaultValue}) {
    return _preferences.get(key) ?? defaultValue;
  }

  @override
  String getString(String key, {String? defaultValue}) {
    return _preferences.get(key) ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool? value, {bool? defaultValue}) {
    return _preferences.put(key, value);
  }

  @override
  Future<void> setDouble(String key, double? value, {double? defaultValue}) {
    return _preferences.put(key, value);
  }

  @override
  Future<void> setInt(String key, int? value, {int? defaultValue}) {
    return _preferences.put(key, value);
  }

  @override
  Future<void> setString(String key, String? value, {String? defaultValue}) {
    return _preferences.put(key, value);
  }

//dart Future setObject(String key, T? value) async { if (T is int || value is int) { await _preferences?.setInt(key, value as int); } if (T is double || value is double) { await _preferences?.setDouble(key, value as double); } if (T is bool || value is bool) { await _preferences?.setBool(key, value as bool); } if (T is String || value is String) { await _preferences?.setString(key, value as String); } throw Exception('No Implementation Found'); }
  @override
  Future<void> setObject<T>(String key, T? value) {
    return _preferences.put(key, value);
  }

  @override
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  @override
  Set getKeys() {
    return _preferences.keys.toSet();
  }

  @override
  Future<void> remove(String key) async {
    if (containsKey(key)) {
      await _preferences.delete(key);
    }
  }

  @override
  Future<void> removeAll() async {
    final Set keys = getKeys();
    await _preferences.deleteAll(keys);
  }

  // @override
  // T? getValue<T>(String key, T? defaultValue) {
  //   final value = _preferences.get(key);
  //   if (value is T) {
  //     return value;
  //   }
  //   return defaultValue;
  // }

  @override
  T? getValue<T>(String key, {T? defaultValue}) {
    final value = _preferences.get(key) as T;
    if (value is T) {
      return value;
    }
    return defaultValue;
  }
}
