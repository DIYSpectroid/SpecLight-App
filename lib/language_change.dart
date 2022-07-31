import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'new_ui_components.dart';
import 'package:provider/provider.dart';

class AppLocale extends ChangeNotifier {
  Locale? _locale;

  Locale get locale => _locale ?? Locale('en');

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}

class LanguageChange extends StatelessWidget {
  LanguageChange({Key? key, required this.chooseID}) : super(key: key);
  ValueNotifier<int> chooseID;

  @override
  Widget build(BuildContext context) {
    void _setLanguage(String language) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('language', language);
    }

    var language = Provider.of<AppLocale>(context);
    const double spacing = 12;

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
                  language.changeLocale(Locale('en'));
                  _setLanguage('en');
                },
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              ImageButton(
                imagePath: "assets/poland.png",
                label: "Polski",
                onPressed: () {
                  language.changeLocale(Locale('pl'));
                  _setLanguage('pl');
                },
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              ImageButton(
                imagePath: "assets/ukraine.png",
                label: "Український",
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              ImageButton(
                imagePath: "assets/germany.png",
                label: "Deutsch",
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              ImageButton(
                imagePath: "assets/france.png",
                label: "Français",
              ),
              Padding(padding: EdgeInsets.all(spacing)),
              ImageButton(
                imagePath: "assets/china.png",
                label: "中文",
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
                    currentID: chooseID),
                BottomTab(icon: Icons.photo_library,
                    label: AppLocalizations.of(context)!.examples,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 1,
                    currentID: chooseID),
                SizedBox(width: 50), // The dummy child
                BottomTab(icon: Icons.more_horiz,
                    label: AppLocalizations.of(context)!.resources,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 2,
                    currentID: chooseID),
                BottomTab(icon: Icons.settings,
                    label: AppLocalizations.of(context)!.settings,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    id: 3,
                    currentID: chooseID),
              ],
            ),
          )),
    );
  }
}
