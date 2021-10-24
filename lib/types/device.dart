import 'package:flutter/cupertino.dart';

class Device with ChangeNotifier {
  Device({required this.name, required this.path});

  final String name;
  String path = '';
  int age = 0;

  void increaseAge() {
    this.age++;
    notifyListeners();
  }

  String get getName {
    return this.name;
  }
}