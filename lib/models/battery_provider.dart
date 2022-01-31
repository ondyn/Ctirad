import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:ctirad/screens/settings/app_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class BatteryProvider extends ChangeNotifier {
  BatteryProvider() {
    const Duration oneSec = Duration(seconds: 5);
    Timer.periodic(oneSec, (Timer t) => checkBattery());
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      debugPrint(
          "BatteryProvider receive: ${state.toString().split('.').last}");
      _batteryState = state;
      notifyListeners();
    });
  }
  int _batteryLevel = -1;
  bool _chargeMe = false;
  bool _charged = false;
  BatteryState _batteryState = BatteryState.unknown;
  final Battery _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  bool get isCharged => _charged;
  bool get chargeMe => _chargeMe;

  Future<void> checkBattery() async {
    _batteryLevel = await _battery.batteryLevel;
    processBatteryLevel(_batteryLevel);
    notifyListeners();
  }

  void processBatteryLevel(int newLevel) {
    double max = Settings.getValue<double>(AppSettings.batMax, 100.0);
    double min = Settings.getValue<double>(AppSettings.batMin, 0.0);
    if (newLevel < min) {
      _charged = false;
      _chargeMe = false;
    }

    if (!_charged && newLevel < max) {
      _chargeMe = true;
    } else {
      _chargeMe = false;
    }

    if (newLevel >= max) {
      _chargeMe = false;
      _charged = true;
    }

    debugPrint(
        'newLevel:$newLevel, min:$min, max$max, chargeMe:$_chargeMe, charged:$_charged');
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    super.dispose();
  }
}
