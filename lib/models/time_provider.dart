import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TimeProvider extends ChangeNotifier {
  TimeProvider() {
    initializeDateFormatting(Platform.localeName);
    Intl.defaultLocale = Platform.localeName;
    const Duration oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) => updateTime());
    _formattedDate = DateFormat('EEEE d. M. yyyy').format(DateTime.now());
    _formattedTime = DateFormat('HH:mm').format(DateTime.now());
  }

  late String _formattedDate;
  late String _formattedTime;

  String get formattedDate => _formattedDate;
  String get formattedTime => _formattedTime;

  void updateTime() {
    final DateTime now = DateTime.now();
    final String newDate = DateFormat('EEEE d. M. yyyy').format(now);
    final String newTime = DateFormat('HH:mm').format(now);

    if (_formattedDate != newDate) {
      _formattedDate = newDate;
      notifyListeners();
    }
    if (_formattedTime != newTime) {
      _formattedTime = newTime;
      notifyListeners();
    }
  }
}
