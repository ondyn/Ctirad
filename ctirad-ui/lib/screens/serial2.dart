import 'dart:async';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

import '../api/utils.dart';
import '../models/app.dart';

class Serial2 extends StatefulWidget {
  const Serial2({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Serial2> {
  UsbPort? _port;
  String _status = 'Idle';
  List<Widget> _ports = List<Widget>.empty();
  final List<Widget> _serialData = [];
  bool isHexMode = true;

  StreamSubscription<Uint8List>? _subscription;
  Transaction<Uint8List>? _transaction;
  UsbDevice? _device;

  final TextEditingController _textController = TextEditingController();

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
      if (this.mounted) {
        setState(() {
          _status = 'Disconnected';
        });
      }
      return true;
    }

    _port = await device.create();
    if (await _port!.open() != true) {
      setState(() {
        _status = 'Failed to open port';
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

    _subscription = _transaction!.stream.listen((Uint8List line) {
      setState(() {
        final String recvData = hex.encode(line);
        _serialData.add(Text(recvData));
        print('Receive: $line text: $recvData');

        Provider.of<AppModel>(context, listen: false)
            .updateTemperature(line[2]);

        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = 'Connected';
    });
    return true;
  }

  Future<void> _getPorts() async {
    _ports = List<ListTile>.empty();
    final List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    for (final UsbDevice device in devices) {
      _ports.add(ListTile(
          leading: const Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(
              device.manufacturerName != null ? device.manufacturerName! : ''),
          trailing: ElevatedButton(
            child: Text(_device == device ? 'Disconnect' : 'Connect'),
            onPressed: () {
              _connectTo(_device == device ? null : device).then((bool res) {
                _getPorts();
              });
            },
          )));
    }

    setState(() {
      print(_ports);
    });
  }

  String formatReceivedData(recv) {
    if (isHexMode) {
      return recv
          .map((List<int> char) => char.map((int c) => intToHex(c)).join())
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
    _connectTo(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(_ports.isNotEmpty
          ? 'Available Serial Ports'
          : 'No serial devices available'),
      ..._ports,
      Text('Status: $_status\n'),
      Text('info: ${_port.toString()}\n'),
      ListTile(
        title: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Text To Send',
          ),
        ),
        trailing: ElevatedButton(
          onPressed: _port == null
              ? null
              : () async {
                  if (_port == null) {
                    return;
                  }
                  final String data = '${_textController.text}\r\n';
                  await _port!.write(Uint8List.fromList(data.codeUnits));
                  _textController.text = '';
                },
          child: const Text('Send'),
        ),
      ),
      const Text('Result Data'),
      ..._serialData,
    ]);
  }
}
