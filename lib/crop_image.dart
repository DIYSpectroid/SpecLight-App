import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis_page.dart';
import 'image_analysis/alogrithm_factory.dart';

final ImagePicker picker = ImagePicker();

class CropPhotoPage extends StatefulWidget{

  const CropPhotoPage({Key? key, required this.imageFile, required this.prefs}) : super(key: key);

  final File? imageFile;
  final SharedPreferences prefs;

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();

}



class _CropPhotoPageState extends State<CropPhotoPage> {

  CroppedFile? croppedFile;
  Algorithm algorithm = Algorithm.hsvPositionPolynomialSureBounds;
  Grating grating = Grating.grating1000;
  late final Future<CroppedFile>? temp = cropImage();


  Future<CroppedFile> cropImage() async {
      croppedFile = await ImageCropper.platform.cropImage(
        sourcePath: widget.imageFile!.path,
        aspectRatioPresets: [
          //CropAspectRatioPreset.square,
          // CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          // CropAspectRatioPreset.ratio4x3,
          // CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: AppLocalizations.of(context)!.crop_header,
              toolbarColor: Theme.of(context).primaryColor,
              statusBarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        ],
    );
      return croppedFile!;
  }

  @override
  Widget build(BuildContext context) {

    if(widget.prefs.containsKey("grating"))
    {
      grating = Grating.values[widget.prefs.getInt("grating")!];
    }
    else
    {
      widget.prefs.setInt("grating", Grating.grating1000.index);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(AppLocalizations.of(context)!.crop_header, style: TextStyle(color: Colors.white),),
      ),
      body: Center(
      child: FutureBuilder<CroppedFile?>(
      future: temp,
      builder: (BuildContext context, AsyncSnapshot<CroppedFile?> snapshot){
        if(snapshot.hasData){
          return  Column(
              children:
              [
                Expanded(
                  child: ListView(
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Image.file(File(snapshot.data!.path)),
                      ),
                    ]
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
                                    (context) => CropPhotoPage(imageFile: File(snapshot.data!.path), prefs: widget.prefs),));
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
                                      (context) => AnalysisPage(imageFilePath: snapshot.data!.path, algorithm: this.algorithm, grating: this.grating, prefs: widget.prefs),));
                            },
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: Text(AppLocalizations.of(context)!.next),
                          )
                      )
                    ]
                ),
              ]
          );
        }
        else if(snapshot.hasError){
          return const Text("Something went wrong");
        }
        else {
          return const CircularProgressIndicator();
        }
        // if(snapshot.hasData){
        //   //return Image.file(File(snapshot.data!.path));
        //   Navigator.push((context),
        //       MaterialPageRoute(builder:
        //           (context) => AnalysisPage(imageFilePath: snapshot.data!.path),));
        //   return const Text("You shouldn't see this");
        // } else{
        //   return const Text("Something went wrong :(");
        // }
      }
      ),
      ),
    );
  }
}