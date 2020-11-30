import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'package:dog_breeds/helpers/tf_helper.dart';

// Main application
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MainScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class MainScreen extends StatefulWidget {
  final CameraDescription camera;

  MainScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @overrideew
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  Future<dynamic> _loadModelFuture;
  TfEngine engine = TfEngine();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    // Initialize engine
    _loadModelFuture = engine.loadModel();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    engine.disposeModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Column(
              children: <Widget>[
                Expanded(child: CameraPreview(_controller)),
                Text('Chihuahua'),
                Text('Chihuahua'),
                Text('Chihuahua'),
                Text('Chihuahua'),
                Text('Chihuahua')
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          await _loadModelFuture;
          await _initializeControllerFuture;

          final path = join(
            // Store the picture in the temp directory.
            // Find the temp directory using the `path_provider` plugin.
            (await getTemporaryDirectory()).path,
            '${DateTime.now()}.jpg',
          );
          await _controller.takePicture(path);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PredictScreen(
                engine: engine,
                path: path,
              ),
            ),
          );
        },
      ),
    );
  }
}
