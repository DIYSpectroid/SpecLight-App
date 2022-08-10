import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectroid/image_analysis/data_extraction/light_hue_conversion_extractor.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spectroid/library.dart';
import 'package:spectroid/resources.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'camera.dart';
import 'language_change.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cameras = await availableCameras();
  CameraDescription firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera, prefs: prefs));
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
  MyApp({Key? key, required this.camera, required this.prefs}) : super(key: key);

  final CameraDescription camera;
  SharedPreferences prefs;


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
                  bodyText1: TextStyle(color: Colors.black, fontSize: 16),
                  headline6: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              home: MainPage(camera: camera, chooseID: ValueNotifier<int>(0), prefs: prefs),
            );
          }
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key, required this.camera, required this.chooseID, required this.prefs}) : super(key: key);
  final CameraDescription camera;
  SharedPreferences prefs;
  ValueNotifier<int> chooseID ;
  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
    void _loadLanguage() async {
      var language = Provider.of<AppLocale>(context, listen: false);
      setState(() {
        if(widget.prefs.containsKey('language')) {
          language.changeLocale(Locale(widget.prefs.getString('language')!));
        }
        else
        {
          widget.prefs.setString('language', language.locale.toString());
        }
      });
    }

    void initState() {
      super.initState();
      _loadLanguage();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: widget.chooseID,
          builder: (context, value, _) {
            return IndexedStack(
                index: value,
                children: [
                  CameraPage(camera: widget.camera, chooseID: widget.chooseID),
                  LibraryPage(chooseID: widget.chooseID, prefs: widget.prefs),
                  ResorcesPage(chooseID: widget.chooseID),
                  LanguageChange(chooseID: widget.chooseID)
                ]
            );
          })
      );
    }

}


