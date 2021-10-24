import 'package:ctirad/pages/serial2.dart';
import 'package:ctirad/stores/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'clock.dart';

class HomePage extends StatefulWidget {
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
    AppModel store = Provider.of<AppModel>(context, listen: true);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: AppBar(
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed("/setting");
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.wb_sunny_outlined)),
                Tab(icon: Icon(Icons.device_thermostat)),
              ],
            ),
            title: Text('Ctirad'),
          ),
        ),
        body: TabBarView(
          children: [
            ClockPage(),
            Serial2(),
            Center(
              child: Column(
                children: [
                  Text('${store.temperature}'),
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
                  Text('${store.baudrate}'),
                  OutlinedButton(
                    onPressed: _incrementCounter,
                    child: Text('TextButton'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
