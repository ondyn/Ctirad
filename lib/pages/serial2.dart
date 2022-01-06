import 'dart:async';
import 'dart:typed_data';

import 'package:ctirad/stores/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:convert/convert.dart';
import '../utils.dart';

class Serial2 extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Serial2> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  List<Widget> _serialData = [];
  bool isHexMode = true;

  StreamSubscription<Uint8List>? _subscription;
  Transaction<Uint8List>? _transaction;
  UsbDevice? _device;

  TextEditingController _textController = TextEditingController();

  Future<bool> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        19200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.terminated(
        _port!.inputStream as Stream<Uint8List>,
        Uint8List.fromList([0xBE, 0xEF]));

    _subscription = _transaction!.stream.listen((line) {
      setState(() {
        String recvData = hex.encode(line);
        _serialData.add(Text(recvData));
        print("Receive: $line text: ${recvData}");

        Provider.of<AppModel>(context, listen: false)
            .updateTemperature(line[2]);

        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(
              device.manufacturerName != null ? device.manufacturerName! : ''),
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {
      print(_ports);
    });
  }

  String formatReceivedData(recv) {
    if (isHexMode) {
      return recv
          .map((List<int> char) => char.map((c) => intToHex(c)).join())
          .join();
    } else {
      return recv.map((List<int> char) => String.fromCharCodes(char)).join();
    }
  }

  List<int> formatSentData(String sendStr) {
    if (isHexMode) {
      return hexToUnits(sendStr);
    } else {
      return sendStr.codeUnits;
    }
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(_ports.length > 0
          ? "Available Serial Ports"
          : "No serial devices available"),
      ..._ports,
      Text('Status: $_status\n'),
      Text('info: ${_port.toString()}\n'),
      ListTile(
        title: TextField(
          controller: _textController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Text To Send',
          ),
        ),
        trailing: ElevatedButton(
          child: Text("Send"),
          onPressed: _port == null
              ? null
              : () async {
                  if (_port == null) {
                    return;
                  }
                  String data = _textController.text + "\r\n";
                  await _port!.write(Uint8List.fromList(data.codeUnits));
                  _textController.text = "";
                },
        ),
      ),
      Text("Result Data"),
      ..._serialData,
    ]);
  }
}
