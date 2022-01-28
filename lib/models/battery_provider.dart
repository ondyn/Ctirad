import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class BatteryProvider extends ChangeNotifier {
  BatteryProvider() {
    const Duration oneSec = Duration(seconds: 5);
    Timer.periodic(oneSec, (Timer t) => getBattery());
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      print("BatteryProvider receive: ${state.toString().split('.').last}");
      _batteryState = state;
      notifyListeners();
    });
  }
  int _batteryLevel = -1;
  BatteryState _batteryState = BatteryState.unknown;
  final Battery _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;

  Future<void> getBattery() async {
    _batteryLevel = await _battery.batteryLevel;
    notifyListeners();
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    super.dispose();
  }
}
