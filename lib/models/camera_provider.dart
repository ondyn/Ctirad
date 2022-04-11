import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider extends ChangeNotifier {
  CameraProvider() {
    _init();
    // const Duration period = Duration(seconds: 5);
    // Timer.periodic(period, (Timer t) => getImage());
  }

  List<CameraDescription> cameras = <CameraDescription>[];
  late CameraController _controller;
  late XFile? image;

  Future<void> _init() async {
    // called in main.dart
    // WidgetsFlutterBinding.ensureInitialized();
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e.code + (e.description ?? ''));
    }

    // print available cameras
    debugPrint('cameras: ${cameras.map((CameraDescription c) {
      return 'name=${c.name} dir=${c.lensDirection} ori=${c.sensorOrientation}; ';
    }).reduce((String a, String b) => a + b)}');

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras[1],
      // Define the resolution to use.
      ResolutionPreset.max,
    );
    await _controller.initialize();
    debugPrint('camera init done');
    const Duration period = Duration(seconds: 5);
    Timer.periodic(period, (Timer t) => getImage());
  }

  Future<void> getImage() async {
    try {
      debugPrint('getImage...');
      image = await _controller.takePicture();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
