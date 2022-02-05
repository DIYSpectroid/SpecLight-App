
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/image_analysis.dart';
import 'package:image/image.dart' as img;


final ImagePicker picker = ImagePicker();

class AnalysisPage extends StatefulWidget{

  const AnalysisPage({Key? key, required this.imageFilePath}) : super(key: key);

  final String? imageFilePath;


  @override
  State<AnalysisPage> createState() => _AnalysisPageState();

}

class _AnalysisPageState extends State<AnalysisPage> {
  Future<List<int>>? imagePixels;
  int? width;
  int? height;
  File? imageFile;

  Future<void> getDimensions() async {
    Image image = Image.file(File(widget.imageFilePath!));
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image info = await completer.future;
    width = info.width;
    height = info.height;
  }

  Future<List<int>> analyzeImage() async {
    await getDimensions();
    imagePixels = ImageAnalysis.getBytes(widget.imageFilePath!);
    return imagePixels!;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Photo analysis"),
      ),
      body: Center(
        child:
        FutureBuilder<List<int>>(
            future: analyzeImage(),
            builder: (BuildContext context, AsyncSnapshot<List<int>?> snapshot) {
              if(snapshot.hasData){
                img.Image image = img.Image.fromBytes(width!, height!, ImageAnalysis.getRGBABytesFromABGRInts(snapshot.data!));
                Uint8List bytes = Uint8List.fromList(img.encodePng(image));
                return Image.memory(bytes, width: width!.toDouble(), height: height!.toDouble());
              } else{
                return const Text("Please wait for analysis...");
              }
            }
        ),
        ),
      );
  }
}