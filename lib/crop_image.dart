import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'analysis_page.dart';
import 'image_analysis.dart';

final ImagePicker picker = ImagePicker();

class CropPhotoPage extends StatefulWidget{

  const CropPhotoPage({Key? key, required this.imageFile}) : super(key: key);

  final File? imageFile;

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();

}



class _CropPhotoPageState extends State<CropPhotoPage> {
  File? croppedFile;
  Algorithm algorithm = Algorithm.hsvPositionBasedPolynomial;
  Grating grating = Grating.grating1000;
  late final Future<File>? temp = cropImage();

  Future<File> cropImage() async {
      croppedFile = await ImageCropper.cropImage(
        sourcePath: widget.imageFile!.path,
        aspectRatioPresets: [
          //CropAspectRatioPreset.square,
          // CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          // CropAspectRatioPreset.ratio4x3,
          // CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: AppLocalizations.of(context)!.crop_header,
            toolbarColor: Colors.grey,
            toolbarWidgetColor: Colors.black,
            activeControlsWidgetColor: Colors.grey,
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
    );
      return croppedFile!;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(AppLocalizations.of(context)!.crop_header),
      ),
      body: Center(
      child: FutureBuilder<File?>(
      future: temp,
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot){
        if(snapshot.hasData){
          return  Column(
              children:
              [
                Expanded(
                  child: ListView(
                    children: [
                      DropdownButton<Algorithm>(
                        value: algorithm,
                        onChanged: (Algorithm? newValue) {
                          setState(() {
                            algorithm = newValue!;
                          });
                        },
                        items: Algorithm.values.map((Algorithm classType) {
                          return DropdownMenuItem<Algorithm>(
                              value: classType,
                              child: Text(classType.toString()));
                        }).toList()
                      ),
                      DropdownButton<Grating>(
                          value: grating,
                          onChanged: (Grating? newValue) {
                            setState(() {
                              grating = newValue!;
                            });
                          },
                          items: Grating.values.map((Grating classType) {
                            return DropdownMenuItem<Grating>(
                                value: classType,
                                child: Text(classType.toString()));
                          }).toList()
                      ),
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
                                    (context) => CropPhotoPage(imageFile: File(snapshot.data!.path)),));
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
                                      (context) => AnalysisPage(imageFilePath: snapshot.data!.path, algorithm: this.algorithm, grating: this.grating,),));
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