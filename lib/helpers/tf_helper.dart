import 'dart:io';
import 'dart:typed_data';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

final int WIDTH = 160;
final int HEIGHT = 160;

class TfEngine {
  bool loaded = false;

  // Loads the dog breed predictor model to tflite
  Future loadModel() async {
    String res = await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
    print('Engine loaded: ' + res);
    loaded = true;
  }

  // make inference on one frame
  dynamic predictStream(CameraImage image) async {
    // TODO
  }

  // Produce test prediction for Rottweiler
  Future<String> predict(String path) async {
    if (!loaded) {
      await this.loadModel();
    }
    // Loading the image
    img.Image picture = img.copyResize(
      img.decodeJpg(File(path).readAsBytesSync()),
      width: WIDTH,
      height: HEIGHT,
    );

    var _path = '${path}_transformed.jpg';
    File(_path).writeAsBytesSync(img.encodeJpg(picture));

    var recognitions = await Tflite.runModelOnImage(
      path: _path,
      numResults: 5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    return recognitions[0]['label'];
  }

  void disposeModel() {
    loaded = false;
    Tflite.close();
  }
}

class PredictScreen extends StatelessWidget {
  final TfEngine engine;
  final String path;

  // Constructor
  const PredictScreen({
    @required this.engine,
    @required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
//        child: Text(this.engine.predict(this.image)),
        child: FutureBuilder(
          future: engine.predict(this.path),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
