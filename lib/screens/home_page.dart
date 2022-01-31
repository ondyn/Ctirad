import 'package:ctirad/screens/battery_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/battery_provider.dart';
import 'clock.dart';
import 'serial2.dart';
import 'settings/app_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  openAppSettings(context);
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.battery_std)),
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.wb_sunny_outlined)),
                Tab(icon: Icon(Icons.device_thermostat)),
              ],
            ),
            title: const Text('Ctirad'),
          ),
        ),
        body: TabBarView(
          children: [
            BatteryScreen(),
            ClockPage(),
            const Serial2(),
            Center(
              child: Column(
                children: const [
                  Text('ahoj'),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const Text('baudrate'),
                  OutlinedButton(
                    onPressed: _incrementCounter,
                    child: const Text('TextButton'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openAppSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => AppSettings(),
    ));
  }
}
