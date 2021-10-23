import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      title: 'Ctirad',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Ctirad'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.wb_sunny_outlined)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
            title: Text(widget.title),
          ),
        ),
        body: TabBarView(
          children: [
            ClockPage(),
            Icon(Icons.directions_car),
            Icon(Icons.wb_sunny_outlined),
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
