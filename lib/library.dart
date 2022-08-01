import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'new_ui_components.dart';

class LibraryPage extends StatelessWidget {

  LibraryPage({Key? key, required this.chooseID}) : super(key: key);
  ValueNotifier<int> chooseID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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