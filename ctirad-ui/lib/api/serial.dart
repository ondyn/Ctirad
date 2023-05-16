import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class Name extends ChangeNotifier {
  late UsbPort? _port;
  final String _status = 'Idle';
  final List<Widget> _ports = <Widget>[];
  final List<Widget> _serialData = <Widget>[];
  late StreamSubscription<Uint8List>? _subscription;
  late Transaction<Uint8List>? _transaction;
  late UsbDevice? _device;
}
