import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'package:provider/provider.dart';

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    const double spacing = 8;

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.credits_header, style: TextStyle(fontFamily: 'Proxy', fontSize: 28)),
          centerTitle: true,
        ),

        body: Center(
          child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              children: [
                Text(AppLocalizations.of(context)!.authors, style: TextStyle(fontFamily: 'Franklin', fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                Padding(padding: EdgeInsets.all(spacing)),

                Text("Ryszard Błażej", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Text("Jakub Hulek", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Text("Łukasz Ruba", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.all(spacing * 2)),

                Text(AppLocalizations.of(context)!.supervisors, style: TextStyle(fontFamily: 'Franklin', fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.all(spacing)),

                Text("dr Joanna Janik-Kokoszka", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Text("mgr Roman Kokoszka", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.all(spacing * 2)),

                Text(AppLocalizations.of(context)!.special_thanks, style: TextStyle(fontFamily: 'Franklin', fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.all(spacing)),

                Text("XYZ", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Text("XYZ", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Text("XYZ", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
                Text("XYZ", style: TextStyle(fontFamily: 'Franklin', fontSize: 18), textAlign: TextAlign.center),
              ]
          ),
        )
    );
  }
}