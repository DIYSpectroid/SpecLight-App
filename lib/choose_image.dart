


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

  var image;

  Future<XFile?> choosePhoto() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: const Text("Choose photo to analyze"),
      ),
      body: Center(
          child: FutureBuilder<XFile?>(
            future: choosePhoto(),
            builder: (BuildContext context, AsyncSnapshot<XFile?> snapshot){
              if(snapshot.hasData){
                return  Container(
                  color: Colors.grey[500],
                  child: Center(child: Image.file(File(snapshot.data!.path))),
                );
              } else {
                return const Text("Loading photo...");
              }
            },
          )
      ),
    );
  }
}