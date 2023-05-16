import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  late Object _device;
  int _baudrate = 9600;
  int _temp = 0;

  Object get device => _device;
  int get baudrate => _baudrate;
  int get temperature => _temp;

  void updateDevice(Object device) {
    _device = device;
    notifyListeners();
  }

  void updateBaudrate(int baudrate) {
    _baudrate = baudrate;
    notifyListeners();
  }

  void updateTemperature(int temp) {
    _temp = temp;
    notifyListeners();
  }
}