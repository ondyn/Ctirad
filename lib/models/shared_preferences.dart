import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> restoreSharedPreferences(String key) async {
  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  return sharedPrefs.get(key) ?? false;
}

dynamic saveSharedPreferences(String key, dynamic value) async {
  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  if (value is bool) {
    sharedPrefs.setBool(key, value);
  } else if (value is String) {
    sharedPrefs.setString(key, value);
  } else if (value is int) {
    sharedPrefs.setInt(key, value);
  } else if (value is double) {
    sharedPrefs.setDouble(key, value);
  } else if (value is List<String>) {
    sharedPrefs.setStringList(key, value);
  }
}
