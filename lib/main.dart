import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';

import 'models/battery_provider.dart';
import 'models/cache_provider.dart';
import 'models/tab_manager.dart';
import 'screens/home_page.dart';

void main() {
  initSettings().then((_) {
    runApp(const Ctirad());
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: HiveCache(),
  );
}

class Ctirad extends StatelessWidget {
  const Ctirad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      title: 'Ctirad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<BatteryProvider>(
              create: (BuildContext context) => BatteryProvider()),
          ChangeNotifierProvider<TabManager>(
              create: (BuildContext context) => TabManager())
        ],
        child: const HomePage(),
      ),
    );
  }
}
