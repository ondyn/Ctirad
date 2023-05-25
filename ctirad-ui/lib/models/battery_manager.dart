import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'shared_preferences.dart';

class XXBatteryManager extends ChangeNotifier {
  XXBatteryManager() {
    restoreSharedPreferences(prefMinChargingKey).then((dynamic value) {
      _minChargingLevel = value;
      notifyListeners();
    });
    restoreSharedPreferences(prefMaxChargingKey).then((dynamic value) {
      _maxChargingLevel = value;
      notifyListeners();
    });
  }

  static const String prefMinChargingKey = 'minCharging';
  static const String prefMaxChargingKey = 'maxCharging';
  int _minChargingLevel = 0;
  int _maxChargingLevel = 100;
  final BatteryState _batteryState = BatteryState.unknown;
  final Battery _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  int get minChargingLevel => _minChargingLevel;
  int get maxChargingLevel => _maxChargingLevel;

  void setMinChargingLevel(int minCharging) {
    _minChargingLevel = minCharging;
    _saveMin();
    notifyListeners();
  }

  void setMaxChargingLevel(int maxCharging) {
    _maxChargingLevel = maxCharging;
    _saveMax();
    notifyListeners();
  }

  Future<void> _saveMin() async {
    saveSharedPreferences(prefMinChargingKey, _minChargingLevel);
  }

  Future<void> _saveMax() async {
    saveSharedPreferences(prefMaxChargingKey, _maxChargingLevel);
  }
}
