
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/image_analysis.dart';
import 'package:image/image.dart' as img;
import 'package:charts_flutter/flutter.dart' as charts;


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

  List<charts.Series<LinearData, double>> createPlotData(Spectrum spectrum) {

    List<LinearData> data = [];
    for (double key in spectrum.getKeys()) {
      data.add(LinearData(key, spectrum.spectrum[key]!));
    }
    data.sort((e1,e2) => e1.x.compareTo(e2.x));
    return [
      charts.Series<LinearData, double>(
        id: 'Colors',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (LinearData xs, _) => xs.x,
        measureFn: (LinearData ys, _) => ys.y,
        data: data,
      )
    ];
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
                Spectrum spectrum = Spectrum(ImageAnalysis.convertRGBtoHSV(ImageAnalysis.getRGBABytesFromABGRInts(snapshot.data!)));
                List<charts.Series<LinearData, double>> seriesList = createPlotData(spectrum);
                List<double> sortedWavelength = spectrum.spectrum.keys.toList();
                sortedWavelength.sort((a, b) => a.compareTo(b));
                return charts.LineChart(
                    seriesList,
                    animate: true,
                    domainAxis: const charts.NumericAxisSpec(
                      tickProviderSpec:
                        charts.BasicNumericTickProviderSpec(zeroBound: false),
                      viewport: charts.NumericExtents(400.0, 700.0))
                );
              }
               else{
                return const Text("Please wait for analysis...");
              }
            }
        ),
        ),
      );
  }
}

class LinearData {
  final double x;
  final double y;

  LinearData(this.x, this.y);
}