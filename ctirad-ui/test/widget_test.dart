// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ctirad_ui/main.dart';
import 'package:ctirad_ui/models/ble/ble_device_connector.dart';
import 'package:ctirad_ui/models/ble/ble_device_interactor.dart';
import 'package:ctirad_ui/models/ble/ble_logger.dart';
import 'package:ctirad_ui/models/ble/ble_scanner.dart';
import 'package:ctirad_ui/models/ble/ble_status_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final FlutterReactiveBle _ble = FlutterReactiveBle();
    final _bleLogger = BleLogger(ble: _ble);
    final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
    final _monitor = BleStatusMonitor(_ble);
    final _connector = BleDeviceConnector(
      ble: _ble,
      logMessage: _bleLogger.addToLog,
    );
    final _serviceDiscoverer = BleDeviceInteractor(
      bleDiscoverServices: _ble.discoverServices,
      readCharacteristic: _ble.readCharacteristic,
      writeWithResponse: _ble.writeCharacteristicWithResponse,
      writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
      subscribeToCharacteristic: _ble.subscribeToCharacteristic,
      logMessage: _bleLogger.addToLog,
    );
    await tester.pumpWidget(Ctirad(
      ble: _ble,
      bleLogger: _bleLogger,
      scanner: _scanner,
      monitor: _monitor,
      serviceDiscoverer: _serviceDiscoverer,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
