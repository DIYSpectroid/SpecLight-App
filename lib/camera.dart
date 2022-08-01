import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:spectroid/rhombus.dart';
import 'crop_image.dart';
import 'new_ui_components.dart';

class CameraPage extends StatefulWidget {

  const CameraPage({Key? key, required this.camera, required this.chooseID}) : super(key: key);
  final CameraDescription camera;
  final ValueNotifier<int> chooseID;
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
    _controller.lockCaptureOrientation();
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
        title: Text(AppLocalizations.of(context)!.choose_header, style: Theme.of(context).textTheme.headline6,),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.photo_library, color: Colors.white))
        ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.scale(
        scale: 1.2,
        child: FloatingActionButton(
          // Provide an onPressed callback.
          onPressed: () async {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;
              _controller.setFlashMode(FlashMode.off);
              await _controller.lockCaptureOrientation();
              // Attempt to take a picture and then get the location
              // where the image file is saved.
              final image = await _controller.takePicture();
              await Navigator.push((context),
                  MaterialPageRoute(builder:
                      (context) => CropPhotoPage(imageFile: File(image.path)),));
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt, color: Colors.white),
          shape: Rhombus(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 2.0,
          child: Container(
            color: Theme
                .of(context)
                .primaryColor,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BottomTab(icon: Icons.show_chart,
                    label: AppLocalizations.of(context)!.analysis_header,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 0,
                    currentID: widget.chooseID),
                BottomTab(icon: Icons.photo_library,
                    label: AppLocalizations.of(context)!.examples,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 1,
                    currentID: widget.chooseID),
                SizedBox(width: 50), // The dummy child
                BottomTab(icon: Icons.more_horiz,
                    label: AppLocalizations.of(context)!.resources,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 2,
                    currentID: widget.chooseID),
                BottomTab(icon: Icons.settings,
                    label: AppLocalizations.of(context)!.settings,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 3,
                    currentID: widget.chooseID),
              ],
            ),
          )),
    );
  }
}