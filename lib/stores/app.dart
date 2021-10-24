import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  late Object _device;
  int _baudrate = 9600;

  Object get device => _device;
  int get baudrate => _baudrate;

  void updateDevice(Object device) {
    _device = device;
    notifyListeners();
  }

  void updateBaudrate(int baudrate) {
    _baudrate = baudrate;
    notifyListeners();
  }
}