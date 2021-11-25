import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();

class ChoosePhotoPage extends StatefulWidget{

  const ChoosePhotoPage({Key? key}) : super(key: key);

  @override
  State<ChoosePhotoPage> createState() => _ChoosePhotoPageState();

}


class _ChoosePhotoPageState extends State<ChoosePhotoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Choose photo to analyze"),
      ),
      body: Center(
          child: Text('test'),
      ),
    );
  }
}