import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../image_analysis/alogrithm_factory.dart';
import '../image_analysis/grating_settings.dart';
import '../main.dart';
import '../widgets/new_ui_components.dart';
import 'package:provider/provider.dart';

class AppLocale extends ChangeNotifier {
  Locale? _locale;

  Locale get locale => _locale ?? Locale('en');

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}

class LanguageChange extends StatefulWidget{

  LanguageChange({Key? key, required this.chooseID, required this.prefs}) : super(key: key);

  ValueNotifier<int> chooseID;
  final SharedPreferences prefs;

  @override
  State<LanguageChange> createState() => _LanguageChangeState();

}

class _LanguageChangeState extends State<LanguageChange> {

  Grating grating = Grating.grating1000;

  @override
  Widget build(BuildContext context) {
    void _setLanguage(String language) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('language', language);
    }

    if(widget.prefs.containsKey("grating"))
    {
      grating = Grating.values[widget.prefs.getInt("grating")!];
    }
    else
    {
      widget.prefs.setInt("grating", Grating.grating1000.index);
    }

    var language = Provider.of<AppLocale>(context);
    const double spacing = 12;

    void changeLanguage(String locale){
      language.changeLocale(Locale(locale));
      _setLanguage(locale);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.choose_language,
            style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            children: [
              ImageButton(
                imagePath: "assets/united kingdom.png",
                label: "English",
                onPressed: () {
                  changeLanguage('en');
                },
                imageSize: 35,
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              ImageButton(
                imagePath: "assets/poland.png",
                label: "Polski",
                onPressed: () {
                  changeLanguage('pl');
                },
                imageSize: 35,
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              Text(AppLocalizations.of(context)!.choose_const, style: TextStyle(fontSize: 18)),
              DropdownButton<Grating>(
                  value: grating,
                  isExpanded: true,
                  onChanged: (Grating? newValue) {
                    setState(() {
                      grating = newValue!;
                      widget.prefs.setInt("grating", newValue.index);
                    });
                  },
                  items: Grating.values.map((Grating classType) {
                    return DropdownMenuItem<Grating>(
                        value: classType,
                        child: Text(GratingToString[classType]!));
                  }).toList()
              ),
            ]),
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
