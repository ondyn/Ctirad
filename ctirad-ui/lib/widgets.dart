import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class BluetoothIcon extends StatelessWidget {
  const BluetoothIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 64,
        height: 64,
        child: Align(alignment: Alignment.center, child: Icon(Icons.bluetooth)),
      );
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}

class BleStatusNotification extends StatelessWidget {
  const BleStatusNotification({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          IconData ico = Icons.error;
          String text = status.toString();
          switch (status) {
            case BleStatus.ready:
              ico = Icons.bluetooth_connected;
              break;
            case BleStatus.unknown:
              ico = Icons.bluetooth_disabled;
              break;
            case BleStatus.unsupported:
              ico = Icons.bluetooth_disabled;
              break;
            case BleStatus.unauthorized:
              ico = Icons.bluetooth_disabled;
              break;
            case BleStatus.poweredOff:
              ico = Icons.bluetooth_disabled;
              break;
            case BleStatus.locationServicesDisabled:
              ico = Icons.bluetooth_disabled;
              break;
            case null:
              ico = Icons.bluetooth_disabled;
              break;
          }
          return Tooltip(
            message: text,
            child: Icon(ico),
          );
        },
      );
}
