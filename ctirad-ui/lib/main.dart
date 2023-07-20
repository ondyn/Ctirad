import 'package:ctirad_ui/models/ble/ble_device_connector.dart';
import 'package:ctirad_ui/models/ble/ble_device_interactor.dart';
import 'package:ctirad_ui/models/ble/ble_logger.dart';
import 'package:ctirad_ui/models/ble/ble_scanner.dart';
import 'package:ctirad_ui/models/ble/ble_status_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';

import 'models/battery_provider.dart';
import 'models/cache_provider.dart';
import 'models/camera_provider.dart';
import 'models/tab_manager.dart';
import 'models/time_provider.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  initSettings().then((_) {
    runApp(Ctirad(
        ble: _ble,
        bleLogger: _bleLogger,
        scanner: _scanner,
        monitor: _monitor,
        connector: _connector,
        serviceDiscoverer: _serviceDiscoverer));
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: HiveCache(),
  );
}

class Ctirad extends StatelessWidget {
  const Ctirad(
      {Key? key,
      required this.ble,
      this.bleLogger,
      this.scanner,
      this.monitor,
      this.connector,
      this.serviceDiscoverer})
      : super(key: key);

  final FlutterReactiveBle ble;
  final bleLogger;
  final scanner;
  final monitor;
  final connector;
  final serviceDiscoverer;

  @override
  Widget build(BuildContext context) {
    //full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    final CameraProvider cameraProvider = CameraProvider();
    return MaterialApp(
      title: 'Ctirad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MultiProvider(
        providers: [
          Provider.value(value: scanner),
          Provider.value(value: monitor),
          Provider.value(value: connector),
          Provider.value(value: serviceDiscoverer),
          Provider.value(value: bleLogger),
          StreamProvider<BleScannerState?>(
            create: (_) => scanner.state,
            initialData: const BleScannerState(
              discoveredDevices: [],
              scanIsInProgress: false,
            ),
          ),
          StreamProvider<BleStatus?>(
            create: (_) => monitor.state,
            initialData: BleStatus.unknown,
          ),
          StreamProvider<ConnectionStateUpdate>(
            create: (_) => connector.state,
            initialData: const ConnectionStateUpdate(
              deviceId: 'Unknown device',
              connectionState: DeviceConnectionState.disconnected,
              failure: null,
            ),
          ),
          ChangeNotifierProvider<BatteryProvider>(
              create: (BuildContext context) => BatteryProvider()),
          ChangeNotifierProvider<TabManager>(
              create: (BuildContext context) => TabManager()),
          ChangeNotifierProvider<TimeProvider>(
              create: (BuildContext context) => TimeProvider()),
          // ChangeNotifierProvider<CameraProvider>(
          //     create: (BuildContext context) => CameraProvider()),
          ChangeNotifierProvider<CameraProvider>.value(value: cameraProvider)
        ],
        child: const HomePage(),
      ),
    );
  }
}
