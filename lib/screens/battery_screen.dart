import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/battery_provider.dart';
import '../models/cache_provider.dart';
import 'settings/app_settings_page.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Consumer<BatteryProvider>(builder:
          (BuildContext context, BatteryProvider provider, Widget? child) {
        return Column(
          children: [
            Text('${provider.batteryLevel}%'),
            Text('status: ${provider.batteryState.toString().split('.').last}'),
            Text('charge me: ${provider.chargeMe}'),
            Text('charged: ${provider.isCharged}'),
          ],
        );
      }),
      ValueListenableBuilder<Box>(
          valueListenable: Hive.box(HiveCache.keyName).listenable(),
          builder: (context, box, widget) {
            return Column(
              children: [
                Center(
                    child: Text(
                        'bat max: ${box.get(AppSettings.batMax, defaultValue: 80).round()}%')),
                Center(
                    child: Text(
                        'bat min: ${box.get(AppSettings.batMin, defaultValue: 20).round()}%')),
              ],
            );
          }),
    ]);
  }
}
