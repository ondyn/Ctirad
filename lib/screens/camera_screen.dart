import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/camera_provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Consumer<CameraProvider>(builder:
          (BuildContext context, CameraProvider provider, Widget? child) {
        return Column(
          children: [
            Text('${provider.cameras.length} cameras'),
            // if (provider.image != null) Image.file(File(provider.image!.path)),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: provider.cameraPreview,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: Colors.grey,
                  width: 3.0,
                ),
              ),
            )
          ],
        );
      }),
    ]);
  }
}
