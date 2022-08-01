import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_ui_components.dart';
import 'overview.dart';

class LibraryPage extends StatelessWidget {
  LibraryPage({Key? key, required this.chooseID, required this.prefs}) : super(key: key);
  ValueNotifier<int> chooseID;

  SharedPreferences prefs;

  Future<List<dynamic>> OpenDatabase() async {
    String jsonString = await rootBundle.loadString('assets/testspectra.json');
    List<dynamic> json = jsonDecode(jsonString);
    return json;
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = <String>[AppLocalizations.of(context)!.category0, AppLocalizations.of(context)!.category1];
    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.of(context)!.examples,
        style: Theme.of(context).textTheme.headline6,
      ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.filter_alt, color: Colors.white))
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
          future:
              OpenDatabase(), // a previously-obtained Future<String> or null
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 185,
                      ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Card(
                      child: InkWell(
                        splashColor:
                            Theme.of(context).accentColor.withAlpha(30),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OverviewPage(index: index, prefs: prefs)),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(snapshot.data![index]["example_photo"], width: double.infinity, height: 100),
                            Container(
                              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                              child: Align(
                                  child: Text(snapshot.data![index]["name_" + prefs.getString('language')!],
                                      style: TextStyle(fontSize: 20)),
                                  alignment: Alignment.centerLeft),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              child: Align(
                                  child: Text(
                                      categories[snapshot.data![index]["class"]],
                                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                                  alignment: Alignment.centerLeft),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              return Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).accentColor));
            }
          }),
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 2.0,
          child: Container(
            color: Theme.of(context).primaryColor,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BottomTab(
                    icon: Icons.show_chart,
                    label: AppLocalizations.of(context)!.analysis_header,
                    color: Theme.of(context).primaryColor,
                    id: 0,
                    currentID: chooseID),
                BottomTab(
                    icon: Icons.photo_library,
                    label: AppLocalizations.of(context)!.examples,
                    color: Theme.of(context).primaryColor,
                    id: 1,
                    currentID: chooseID),
                SizedBox(width: 50), // The dummy child
                BottomTab(
                    icon: Icons.more_horiz,
                    label: AppLocalizations.of(context)!.resources,
                    color: Theme.of(context).primaryColor,
                    id: 2,
                    currentID: chooseID),
                BottomTab(
                    icon: Icons.settings,
                    label: AppLocalizations.of(context)!.settings,
                    color: Theme.of(context).primaryColor,
                    id: 3,
                    currentID: chooseID),
              ],
            ),
          )),
    );
  }
}
