import 'package:ctirad/pages/home.dart';
import 'package:ctirad/pages/settings.dart';
import 'package:ctirad/pages/settings/setting_baudrate.dart';
import 'package:ctirad/stores/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/battery_provider.dart';
import 'pages/settings/setting_device.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AppModel>(
      create: (context) => AppModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      title: 'Ctirad',
      theme: ThemeData.dark(),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BatteryProvider()),
        ],
        child: HomePage(),
      ),
      routes: {
        "/setting": (context) => SettingPage(),
        "/setting/device": (context) => SettingDevicePage(),
        "/setting/baudrate": (context) => SettingBaudratePage(),
      },
    );
  }
}
