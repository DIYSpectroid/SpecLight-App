import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'new_ui_components.dart';

class OverviewPage extends StatelessWidget {
  OverviewPage({Key? key, required this.index, required this.prefs})
      : super(key: key);
  int index;
  SharedPreferences prefs;
  LaunchMode launchMode = LaunchMode.externalApplication;

  Future<List<dynamic>> OpenDatabase() async {
    String jsonString = await rootBundle.loadString('assets/testspectra.json');
    List<dynamic> json = jsonDecode(jsonString);
    return json;
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = <String>[
      AppLocalizations.of(context)!.category0,
      AppLocalizations.of(context)!.category1
    ];
    return FutureBuilder(
        future: OpenDatabase(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(
                  color: Colors.white,
                ),
                title: Text(
                  AppLocalizations.of(context)!.overview,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              body: ListView(
                children: [
                  Image.asset(snapshot.data![index]["example_photo"],
                      width: double.infinity),
                  Container(
                    padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 2.0),
                          child: Align(
                              child: Text(
                                  snapshot.data![index]
                                      ["name_" + prefs.getString('language')!],
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                              alignment: Alignment.centerLeft),
                        ),
                        Container(
                          child: Align(
                              child: Text(
                                  categories[snapshot.data![index]["class"]],
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black38)),
                              alignment: Alignment.centerLeft),
                        ),
                        Divider(color: Colors.black, height: 40),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                          child: Align(
                              child: Text(
                                  AppLocalizations.of(context)!.spectrapeaks,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                              alignment: Alignment.centerLeft),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: snapshot.data![index]["peaks"].length,
                            itemBuilder: (BuildContext context, int number) {
                              return Container(
                                  padding: EdgeInsets.fromLTRB(0, 3.0, 0, 3.0),
                                  child: Text(
                                    ("${snapshot.data![index]["peaks"][number]["wavelength"]}" + AppLocalizations.of(context)!.spectradescpart1 + "${snapshot.data![index]["peaks"][number]["intensity"]}" + AppLocalizations.of(context)!.spectradescpart2),
                                  style: TextStyle(color: Colors.black54, fontSize: 16)
                                    ,));
                            })
                      ],
                    ),
                  )
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: OutlinedButton.icon(
                onPressed: () async {
                  Uri url = Uri.parse(snapshot.data![index]["wikipedia_page"]);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: launchMode);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.wikipedia),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
