import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';

class CameraProvider extends ChangeNotifier {
  CameraProvider() {
    _init();
    // const Duration period = Duration(seconds: 5);
    // Timer.periodic(period, (Timer t) => getImage());
  }

  List<CameraDescription> cameras = <CameraDescription>[];
  late CameraController _controller;
  late XFile? image;

  dynamic get cameraPreview {
    return CameraPreview(_controller);
  }

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
    const Duration period = Duration(seconds: 5);
    Timer.periodic(period, (Timer t) => getImage());
  }

  Future<void> getImage() async {
    try {
      image = await _controller.takePicture();
      final File file = File(image!.path);

      final Uint8List fileBytes = file.readAsBytesSync();
      final Map<String, IfdTag> data = await readExifFromBytes(fileBytes);
      // /data/user/0/com.example.ctirad/cache/CAP8082876847936089632.jpg
      if (data.isEmpty) {
        print("No EXIF information found");
        return;
      }

      final String exposureFraction = data['EXIF ExposureTime'].toString();
      try {
        final splitted = exposureFraction.split('/');
        final double expTime = int.parse(splitted[0]) / int.parse(splitted[1]);
        final double brightness = 1 - expTime * 10;
        FlutterScreenWake.setBrightness(brightness);
        print('ExposureTime: $expTime s Brightnes: $brightness');
      } catch (e) {
        print('unable to parse exposure time: $exposureFraction');
      }

/*       if (data.containsKey('EXIF ExposureTime')) {
        print('ExposureTime: ${data['EXIF ExposureTime']}');
      }
      if (data.containsKey('EXIF FNumber')) {
        print('FNumber: ${data['EXIF FNumber']}');
      }
      if (data.containsKey('EXIF ISOSpeedRatings')) {
        print('ISOSpeedRatings: ${data['EXIF ISOSpeedRatings']}');
      } */

      // for (final entry in data.entries) {
      //   print("${entry.key}: ${entry.value}");
      // }
      await file.delete();

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

// I/flutter ( 9198): Image ImageDescription: Exif_JPEG_420
// I/flutter ( 9198): Image Make: UMAX 8C_LTE
// I/flutter ( 9198): Image Model: 8C_LTE
// I/flutter ( 9198): Image Orientation: 0
// I/flutter ( 9198): Image XResolution: 72
// I/flutter ( 9198): Image YResolution: 72
// I/flutter ( 9198): Image ResolutionUnit: Pixels/Inch
// I/flutter ( 9198): Image Software: Software Version v1.1.0
// I/flutter ( 9198): Image DateTime: 2022:04:11 10:23:45
// I/flutter ( 9198): Image Artist: Artist-freed
// I/flutter ( 9198): Image YCbCrPositioning: Centered
// I/flutter ( 9198): Image ImageWidth: 720
// I/flutter ( 9198): Image ImageLength: 1280
// I/flutter ( 9198): Image Copyright: Copyright,Spreadtrum,2011
// I/flutter ( 9198): Image ExifOffset: 442
// I/flutter ( 9198): Image GPSInfo: 1286
// I/flutter ( 9198): EXIF ExposureTime: 1000/33323
// I/flutter ( 9198): EXIF FNumber: 2
// I/flutter ( 9198): EXIF ExposureProgram: Shutter Priority
// I/flutter ( 9198): EXIF ISOSpeedRatings: 80
// I/flutter ( 9198): EXIF ExifVersion: 0220
// I/flutter ( 9198): EXIF DateTimeOriginal: 2022:04:11 10:23:45
// I/flutter ( 9198): EXIF OffsetTime: +02:00
// I/flutter ( 9198): EXIF OffsetTimeOriginal: +02:00
// I/flutter ( 9198): EXIF OffsetTimeDigitized: +02:00
// I/flutter ( 9198): EXIF DateTimeDigitized: 2022:04:11 10:23:45
// I/flutter ( 9198): EXIF ComponentsConfiguration: YCbCr
// I/flutter ( 9198): EXIF ApertureValue: 14/5
// I/flutter ( 9198): EXIF MaxApertureValue: 14/5
// I/flutter ( 9198): EXIF LightSource: Unknown
// I/flutter ( 9198): EXIF Flash: Flash did not fire
// I/flutter ( 9198): EXIF FocalLength: 2111/500
// I/flutter ( 9198): EXIF SubSecTime: 10
// I/flutter ( 9198): EXIF SubSecTimeOriginal: 100
// I/flutter ( 9198): EXIF SubSecTimeDigitized: 20
// I/flutter ( 9198): EXIF FlashPixVersion: 0100
// I/flutter ( 9198): EXIF ColorSpace: sRGB
// I/flutter ( 9198): EXIF ExifImageWidth: 1280
// I/flutter ( 9198): EXIF ExifImageLength: 720
// I/flutter ( 9198): EXIF Tag 0xA006: 0
// I/flutter ( 9198): EXIF FileSource: Digital Camera
// I/flutter ( 9198): EXIF ExposureMode: Auto Exposure
// I/flutter ( 9198): EXIF WhiteBalance: Auto
// I/flutter ( 9198): EXIF SceneCaptureType: Standard
// I/flutter ( 9198): EXIF ImageUniqueID: IMAGE 2022:04:11 10:23:45