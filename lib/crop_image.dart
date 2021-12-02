import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();

class CropPhotoPage extends StatefulWidget{

  const CropPhotoPage({Key? key}) : super(key: key);

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();

}


class _CropPhotoPageState extends State<CropPhotoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Crop photo to analyze"),
      ),
      body: Center(
          child: Text('test'),
      ),
    );
  }
}