import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectroid/image_analysis/data_extraction/light_hue_conversion_extractor.dart';
import 'choose_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'language_change.dart';
import 'minor_pages/credits.dart';
import 'new_ui_components.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
  HueConversionData.initialize(false);
  // HueConversionData.initialize(true);
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
                primarySwatch: buildMaterialColor(Color(0xFFD2D0E7)),
              ),
              home: MyHomePage(title: 'SPECLIGHT App'),
            );
          }
      ),
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
  void initState() {
    super.initState();
    _loadLanguage();
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
              onPressed: (){},
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            MenuButton(
              icon: Icons.help_outline,
              label: AppLocalizations.of(context)!.help,
              onPressed: (){},
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            MenuButton(
              icon: Icons.insert_photo_outlined,
              label: AppLocalizations.of(context)!.examples,
              onPressed: (){},
            ),
            Padding(padding: EdgeInsets.all(spacing * 4)),
            MenuButton(
              icon: Icons.share_outlined,
              label: AppLocalizations.of(context)!.share,
              color: Color(0x1AE75EA0),
              onPressed: (){},
            ),
            Padding(padding: EdgeInsets.all(spacing)),
            SizedBox(
              child: Row(
                children:[
                  SquareButton(icon: Icons.settings_outlined, label: AppLocalizations.of(context)!.settings, onPressed: (){
                    Navigator.push((context),
                        MaterialPageRoute(builder:
                            (context) => LanguageChange()));
                  }),
                  Expanded(child: Container()),
                  SquareButton(icon: Icons.language_outlined, label: AppLocalizations.of(context)!.website),
                  Expanded(child: Container()),
                  SquareButton(icon: Icons.person_outline, label: AppLocalizations.of(context)!.credits,
                    onPressed: (){
                    Navigator.push((context),
                        MaterialPageRoute(builder:
                            (context) => CreditsPage(),));
                  },)
                ]
              )
            )

          ]
        )
      ),
    );
  }
}
