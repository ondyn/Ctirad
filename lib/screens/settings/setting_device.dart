import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_temp/device.dart';
import '../../models/app.dart';

class SettingDevicePage extends StatefulWidget {
  const SettingDevicePage({Key? key}) : super(key: key);

  @override
  _SettingDevicePageState createState() => _SettingDevicePageState();
}

class _SettingDevicePageState extends State<SettingDevicePage> {
  List<Device> deviceList = [];

  @override
  void initState() {
    super.initState();
    // findDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _calculation,
        builder: (BuildContext context, AsyncSnapshot<List<Device>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(snapshot.data![index].path),
                    onTap: () {
                      Provider.of<AppModel>(context, listen: false)
                          .updateDevice(snapshot.data![index]);
                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 0.0),
              );
          }
        },
      ),
    );
  }

  // Future<List<Device>> findDevices() async {
  // return await FlutterSerialPort.listDevices();
  // }
  final Future<List<Device>> _calculation = Future<List<Device>>.delayed(
    const Duration(seconds: 2),
    () => [],
  );
}
