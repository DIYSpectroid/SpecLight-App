import 'package:flutter/material.dart';
import 'package:spectroid/light_hue_conversion_extractor.dart';
import 'choose_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'new_ui_components.dart';

void main() {
  runApp(const MyApp());
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
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spectroid',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('pl', ''),
        Locale('uk', ''),
        Locale('fr', ''),
        Locale('de', ''),
        Locale('zh', ''),
        Locale('sv', '')
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: buildMaterialColor(Color(0xFFD2D0E7)),
      ),
      home: const MyHomePage(title: 'SPECLIGHT App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    const double spacing = 12;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title, style: TextStyle(fontFamily: 'Proxy', fontSize: 28)),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(40, spacing * 4, 40, 0),
          children: <Widget>[
            MenuButton(
              icon: Icons.camera_alt,
              label: AppLocalizations.of(context)!.take_analysis,
              onPressed: (){
                Navigator.push((context),
                    MaterialPageRoute(builder:
                        (context) => const ChoosePhotoPage(isCameraChosen: true),));
              },
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            MenuButton(
              icon: Icons.folder_outlined,
              label: AppLocalizations.of(context)!.send_analysis,
              onPressed: (){
                Navigator.push((context),
                    MaterialPageRoute(builder:
                        (context) => const ChoosePhotoPage(isCameraChosen: false),));
                },
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            MenuButton(
              icon: Icons.ondemand_video_outlined,
              label: AppLocalizations.of(context)!.instruction,
              onPressed: (){
                Navigator.push((context),
                    MaterialPageRoute(builder:
                        (context) => const ChoosePhotoPage(isCameraChosen: false),));
              },
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            MenuButton(
              icon: Icons.help_outline,
              label: AppLocalizations.of(context)!.help,
              onPressed: (){
                Navigator.push((context),
                    MaterialPageRoute(builder:
                        (context) => const ChoosePhotoPage(isCameraChosen: false),));
              },
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            MenuButton(
              icon: Icons.insert_photo_outlined,
              label: AppLocalizations.of(context)!.examples,
              onPressed: (){
                Navigator.push((context),
                    MaterialPageRoute(builder:
                        (context) => const ChoosePhotoPage(isCameraChosen: false),));
              },
            ),
            Padding(padding: EdgeInsets.all(spacing * 4)),
            MenuButton(
              icon: Icons.share_outlined,
              label: AppLocalizations.of(context)!.share,
              color: Color(0x1AE75EA0),
              onPressed: (){
                Navigator.push((context),
                    MaterialPageRoute(builder:
                        (context) => const ChoosePhotoPage(isCameraChosen: false),));
              },
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            SizedBox(
              child: Row(
                children:[
                  SquareButton(icon: Icons.settings_outlined, label: AppLocalizations.of(context)!.settings),
                  Expanded(child: Container()),
                  SquareButton(icon: Icons.language_outlined, label: AppLocalizations.of(context)!.website),
                  Expanded(child: Container()),
                  SquareButton(icon: Icons.person_outline, label: AppLocalizations.of(context)!.credits)
                ]
              )
            )

          ]
        )
      ),
    );
  }
}
