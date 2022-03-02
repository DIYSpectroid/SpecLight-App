import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

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
  Algorithm algorithm = Algorithm.position_based;
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
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Crop image',
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

        title: const Text("Crop photo to analyze"),
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
                          label: const Text("Retry"),
                        ),
                      ),
                      Expanded
                        (
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push((context),
                                  MaterialPageRoute(builder:
                                      (context) => AnalysisPage(imageFilePath: snapshot.data!.path, algorithm: this.algorithm),));
                            },
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: const Text("Continue"),
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