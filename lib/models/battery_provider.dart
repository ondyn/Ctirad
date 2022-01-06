import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BatteryProvider extends ChangeNotifier {
  int _batteryLevel = -1;
  BatteryState _batteryState = BatteryState.unknown;
  final _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;

  BatteryProvider() {
    const oneSec = Duration(seconds: 5);
    Timer.periodic(oneSec, (Timer t) => getBattery());
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      print("BatteryProvider receive: ${state.toString().split('.').last}");
      _batteryState = state;
      notifyListeners();
    });
  }

  void getBattery() async {
    _batteryLevel = await _battery.batteryLevel;
    notifyListeners();
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    super.dispose();
  }
}

// Instantiate it


// Access current battery level
// print(await battery.batteryLevel);

// // Be informed when the state (full, charging, discharging) changes
// battery.onBatteryStateChanged.listen((BatteryState state) {
//   // Do something with new state
// });