import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';




class CameraPage extends StatefulWidget{

  const CameraPage({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  State<CameraPage> createState() => _CameraPage();

}


class _CameraPage extends State<CameraPage> {


  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {

    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();


  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.choose_header),
      ),
      body: Center(
        child: Stack(children: <Widget>
        [
          SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              }
              else if(snapshot.hasError){
                return Text(AppLocalizations.of(context)!.error_message);
              }
              else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
                },
              )
            ),
          ]
        ),
      ),

      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
            _controller.setFlashMode(FlashMode.off);
            // Attempt to take a picture and then get the location
            // where the image file is saved.
            final image = await _controller.takePicture();
            Navigator.pop(context, image);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}