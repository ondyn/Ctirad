import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/battery_provider.dart';
import 'battery_screen.dart';
import 'camera_screen.dart';
import 'clock_screen.dart';
import 'serial2.dart';
import 'settings/app_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _screenSaver = false;
  int _counter = 0;
  var _context;
  late TabController _tabController;
  late Timer _timer;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _stopScreenSaver() {
    setState(() {
      _screenSaver = false;
    });
  }

  void _startScreenSaver() {
    print(
        'starting screen saver...........................................................................');
    setState(() {
      _screenSaver = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);

    _tabController.addListener(_handleTabSelection);
    _handleTabSelection();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      print(_tabController.index);
      if (_tabController.index == 0) {
        _timer = Timer(Duration(milliseconds: 10000), _startScreenSaver);
      } else {
        _timer.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screenSaver) {
      return GestureDetector(
          onTap: () {
            _stopScreenSaver();
            _handleTabSelection();
          },
          child: SizedBox.expand(child: ClockScreen()));
    } else {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            actions: <Widget>[
              Consumer<BatteryProvider>(builder: (BuildContext context,
                  BatteryProvider provider, Widget? child) {
                if (provider.batteryState == BatteryState.charging) {
                  return const Icon(Icons.battery_charging_full);
                }
                return const SizedBox.shrink();
              }),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  openAppSettings(context);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: <Tab>[
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.battery_std)),
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.wb_sunny_outlined)),
                Tab(icon: Icon(Icons.device_thermostat)),
                Tab(icon: Icon(Icons.camera_alt)),
              ],
            ),
            title: const Text('Ctirad'),
          ),
        ),
        body: Builder(builder: (context) {
          _context = context;
          return TabBarView(
            controller: _tabController,
            children: <Widget>[
              const ClockScreen(),
              const BatteryScreen(),
              const Serial2(),
              Center(
                child: Column(
                  children: const <Text>[
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
              const CameraScreen(),
            ],
          );
        }),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void openAppSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => AppSettings(),
    ));
  }
}
