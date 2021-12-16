import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();

class CropPhotoPage extends StatefulWidget{

  const CropPhotoPage({Key? key, required this.imageFile}) : super(key: key);

  final File? imageFile;

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();

}




class _CropPhotoPageState extends State<CropPhotoPage> {

  File? croppedFile;



  Future<File> cropImage() async {
      croppedFile = await ImageCropper.cropImage(
        sourcePath: widget.imageFile!.path,
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9
        // ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: Colors.lightGreen,
            toolbarWidgetColor: Colors.black,
            activeControlsWidgetColor: Colors.lightGreen,
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
      future: cropImage(),
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot){
        if(snapshot.hasData){
          return Image.file(File(snapshot.data!.path));
        } else{
          return const Text("Something went wrong :(");
        }
      }
      ),
      ),
    );
  }
}