import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/crop_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'camera_page.dart';

final ImagePicker picker = ImagePicker();

class ChoosePhotoPage extends StatefulWidget{

  const ChoosePhotoPage({Key? key, required this.isCameraChosen}) : super(key: key);

  final bool isCameraChosen;



  @override
  State<ChoosePhotoPage> createState() => _ChoosePhotoPageState();

}


class _ChoosePhotoPageState extends State<ChoosePhotoPage> {

  Future<XFile?> choosePhoto() async {
    if(!widget.isCameraChosen) {
      return await picker.pickImage(source: ImageSource.gallery);
    }
    else {
      WidgetsFlutterBinding.ensureInitialized();
      final cameras = await availableCameras();
      final CameraDescription firstCamera = cameras.first;
      return await Navigator.push((context),
          MaterialPageRoute(builder:
              (context) => CameraPage(camera: firstCamera),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(AppLocalizations.of(context)!.choose_header),
      ),
      body: Center(
          child: FutureBuilder<XFile?>(
            future: choosePhoto(),
            builder: (BuildContext context, AsyncSnapshot<XFile?> snapshot){
              if(snapshot.hasData){
                return  Column(
                  children:
                  [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.file(File(snapshot.data!.path)),
                      ),
                  ),
                  Row(
                      children:
                      [
                        Expanded
                        (
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push((context),
                                  MaterialPageRoute(builder:
                                      (context) => ChoosePhotoPage(isCameraChosen: widget.isCameraChosen),));
                            },
                            icon: const Icon(Icons.update, size: 18),
                            label: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ),
                        Expanded
                        (
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push((context),
                                MaterialPageRoute(builder:
                                  (context) => CropPhotoPage(imageFile: File(snapshot.data!.path)),));
                            },
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: Text(AppLocalizations.of(context)!.next),
                          )
                        )
                      ]
                  ),
                  ]
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
      ),

      /*bottomNavigationBar: BottomNavigationBar(
        items: const [BottomNavigationBarItem(icon: Icon(Icons.update), backgroundColor: Colors.lime, label: "Change image"),
          BottomNavigationBarItem(icon: Icon(Icons.verified_outlined), backgroundColor: Colors.pinkAccent, label: "Analyse image")],
      ),*/
    );
  }
}