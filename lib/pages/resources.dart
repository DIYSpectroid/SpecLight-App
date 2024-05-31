import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utility/openUrl.dart';
import '../widgets/new_ui_components.dart';

class ResorcesPage extends StatelessWidget {
  ResorcesPage({Key? key, required this.chooseID}) : super(key: key);
  ValueNotifier<int> chooseID;
  LaunchMode launchMode = LaunchMode.externalApplication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.of(context)!.resources,
        style: Theme.of(context).textTheme.headline6,
      ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(bottom: 20.0)),
            Text(
              AppLocalizations.of(context)!.website,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(
              height: 36,
              child: TextButton(
                onPressed: () {openUrl("http://hexa.fis.agh.edu.pl/speclight-app/");},
                child: Text("http://hexa.fis.agh.edu.pl/speclight-app/",
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).hintColor)),
                style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
                ),
              ),
            ),
            //Padding(padding: EdgeInsets.only(bottom: 14.0)),
            /*Text(AppLocalizations.of(context)!.youtube,
                style: Theme.of(context).textTheme.bodyText1),
            SizedBox(
              height: 36,
              child: TextButton(
                onPressed: () {openUrl("http://hexa.fis.agh.edu.pl/speclight-app/");},
                child: Align(
                    child: Text("http://hexa.fis.agh.edu.pl/speclight-app/",
                        style: TextStyle(
                            fontSize: 16, color: Theme.of(context).accentColor)),
                    alignment: FractionalOffset.centerLeft),
                style: ButtonStyle(
                  padding:
                  MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
                ),
              ),
            ),

            Padding(padding: EdgeInsets.all(10)),*/

            Text(AppLocalizations.of(context)!.authors, style: Theme.of(context).textTheme.bodyText1),
            Padding(padding: EdgeInsets.all(2)),

            Text("Ryszard Błażej", style: Theme.of(context).textTheme.bodyText2),
            Text("Jakub Hulek", style: Theme.of(context).textTheme.bodyText2),
            Text("Łukasz Ruba", style: Theme.of(context).textTheme.bodyText2),
            Padding(padding: EdgeInsets.all(2 * 2)),

            Text(AppLocalizations.of(context)!.supervisors, style: Theme.of(context).textTheme.bodyText1),
            Padding(padding: EdgeInsets.all(2)),

            Text("dr Joanna Janik-Kokoszka", style: Theme.of(context).textTheme.bodyText2),
            Text("mgr Roman Kokoszka", style: Theme.of(context).textTheme.bodyText2),
            Padding(padding: EdgeInsets.all(2 * 2)),

            //Text(AppLocalizations.of(context)!.special_thanks, style: Theme.of(context).textTheme.bodyText1),
            //Padding(padding: EdgeInsets.all(2)),

            //Text("XYZ", style: Theme.of(context).textTheme.bodyText2),
            //Text("XYZ", style: Theme.of(context).textTheme.bodyText2),
            //Text("XYZ", style: Theme.of(context).textTheme.bodyText2),
            //Text("XYZ", style: Theme.of(context).textTheme.bodyText2),

            Expanded(
              child: Container(
                width: double.infinity,
              ),
            ),

            Text(AppLocalizations.of(context)!.shareEncourage, style: Theme.of(context).textTheme.headline5),
            Padding(padding: EdgeInsets.only(bottom: 15.0)),
            GridView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 50.0
              ),
              children: <Widget>[
                    ImageButton(
                      imagePath: "assets/facebookOrange.png",
                      imageSize: 35,
                      label: "Facebook",
                      color: Color(0xFFbb8000),
                      onPressed: () async{
                        Uri url = Uri.parse("https://www.facebook.com/profile.php?id=100076116576037");
                        if(await canLaunchUrl(url)){
                          await launchUrl(url, mode: launchMode);
                        }else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    ImageButton(
                      imagePath: "assets/instagramOrange.png",
                      imageSize: 35,
                      label: "Instagram",
                      color: Color(0xFFbb8000),
                      onPressed: () async{
                        Uri url = Uri.parse("https://www.instagram.com/skn_hexa?igsh=MWZjYWhlM2ZsaTVqaw==");
                        if(await canLaunchUrl(url)){
                          await launchUrl(url, mode: launchMode);
                        }else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    ImageButton(
                      imagePath: "assets/linkedinOrange.png",
                      imageSize: 35,
                      label: "Linkedin",
                      color: Color(0xFFbb8000),
                      onPressed: () async{
                        Uri url = Uri.parse("https://www.linkedin.com/company/skn-hexa/");
                        if(await canLaunchUrl(url)){
                          await launchUrl(url, mode: launchMode);
                        }else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    ImageButton(
                      imagePath: "assets/twitterOrange.png",
                      imageSize: 35,
                      label: "Twitter",
                      color: Colors.black26,
                      onPressed: null,
                    ),
              ],
            ),
            Padding(padding: EdgeInsets.all(10)),
          ],
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
