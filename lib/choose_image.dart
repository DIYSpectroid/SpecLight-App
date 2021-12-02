import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/crop_image.dart';

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
      return await picker.pickImage(source: ImageSource.camera);
    }
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
                            label: const Text("Retry"),
                          ),
                        ),
                        Expanded
                        (
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push((context),
                                MaterialPageRoute(builder:
                                  (context) => const CropPhotoPage(),));
                            },
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: const Text("Continue"),
                          )
                        )
                      ]
                  ),
                  ]
                );
              } else {
                return const Text("Loading photo...");
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