import 'package:flutter/material.dart';

class TabManager extends ChangeNotifier {
  int activeTab = 0;

  void goToTab(int index) {
    activeTab = index;
    notifyListeners();
  }

  void goToRecipes() {
    activeTab = 1;
    notifyListeners();
  }
}
