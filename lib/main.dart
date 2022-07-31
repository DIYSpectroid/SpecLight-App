import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectroid/light_hue_conversion_extractor.dart';
import 'package:spectroid/rhombus.dart';
import 'choose_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'crop_image.dart';
import 'language_change.dart';
import 'minor_pages/credits.dart';
import 'new_ui_components.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  CameraDescription firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
  HueConversionData.initialize(false);
  HueConversionData.initialize(true);
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppLocale(),
      child: Consumer<AppLocale>(
          builder: (context, locale, child) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales:[
              Locale('en', ''),
              Locale('pl', ''),
              Locale('uk', ''),
              Locale('fr', ''),
              Locale('de', ''),
              Locale('zh', ''),
              Locale('sv', '')
              ],
              locale: locale.locale, // NEW
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: buildMaterialColor(Color(0xFFFA7921)),
                accentColor: buildMaterialColor(Color(0xFFF2AF29)),
                textTheme: TextTheme(
                  headline6: TextStyle(color: Colors.white),
                )
              ),
              home: CameraPage(camera: camera),
            );
          }
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
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
    _loadLanguage();
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



  void _loadLanguage() async {

    final prefs = await SharedPreferences.getInstance();
    var language = Provider.of<AppLocale>(context, listen: false);
    setState(() {
      if(prefs.containsKey('language')) {
        language.changeLocale(Locale(prefs.getString('language')!));
      }
    });
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
            color: Theme.of(context).primaryColor,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BottomTab(icon: Icons.show_chart, label: "Analysis", selected: true, color: Theme.of(context).primaryColor),
                BottomTab(icon: Icons.photo_library, label: "Examples", selected: false, color: Theme.of(context).primaryColor),
                SizedBox(width: 50), // The dummy child
                BottomTab(icon: Icons.more_horiz, label: "Resources", selected: false, color: Theme.of(context).primaryColor),
                BottomTab(icon: Icons.settings, label: "Settings", selected: false, color: Theme.of(context).primaryColor),
              ],
            ),
          )),
    );
  }
}
