import 'package:ctirad_ui/screens/ble_status_screen.dart';
import 'package:ctirad_ui/screens/device_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class BleSettings extends StatelessWidget {
  const BleSettings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Bluetooth LE settings'),
              ),
              body: (status == BleStatus.ready)
                  ? const DeviceListScreen()
                  : BleStatusScreen(status: status ?? BleStatus.unknown));
        },
      );
}
