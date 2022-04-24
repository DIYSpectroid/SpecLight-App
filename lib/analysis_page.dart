
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/image_analysis.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:spectroid/image_data_extraction.dart';


final ImagePicker picker = ImagePicker();

class AnalysisPage extends StatefulWidget{

  const AnalysisPage({Key? key, required this.imageFilePath, required this.algorithm}) : super(key: key);

  final String? imageFilePath;
  final Algorithm algorithm;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();

}

class _AnalysisPageState extends State<AnalysisPage> {
  Future<ImageData>? imageData;
  File? imageFile;

  Future<ImageData> analyzeImage() async {
    imageData = ImageDataExtraction.getImageData(widget.imageFilePath!);
    return imageData!;
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
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (LinearData xs, _) => xs.x,
        measureFn: (LinearData ys, _) => ys.y,
        data: data,
      )
    ];
  }

  Future<Spectrum> getSpectrum() async{
    ImageData imageData = await analyzeImage();
    List<int> rgba = await compute(ImageDataExtraction.getRGBABytesFromABGRInts, imageData.bytes);
    List<HSVPixel> hsvPixels =  await compute(ImageDataExtraction.convertBytesToHSV, rgba);
    List<RGBPixel> rgbPixels = await compute(ImageDataExtraction.convertBytesToRGB, rgba);

    Spectrum spectrum = Spectrum(hsvPixels, imageData.width, imageData.height, rgbPixels, widget.algorithm);
    return spectrum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Photo analysis"),
      ),
      body: Center(
        child:
        FutureBuilder<Spectrum>(
            future: getSpectrum(),
            builder: (BuildContext context, AsyncSnapshot<Spectrum?> snapshot) {
              if(snapshot.hasData){
                List<charts.Series<LinearData, double>> seriesList = createPlotData(snapshot.data!);
                //List<double> sortedWavelength = spectrum.spectrum.keys.toList();
                //sortedWavelength.sort((a, b) => a.compareTo(b));
                return
                ListView(
                  children: [
                    Container(
                    child: charts.LineChart(
                        seriesList,
                        animate: true,
                        domainAxis: const charts.NumericAxisSpec(
                          tickProviderSpec:
                            charts.BasicNumericTickProviderSpec(zeroBound: false),
                          viewport: charts.NumericExtents(Spectrum.wavelengthMin, Spectrum.wavelengthMax))
                    ),
                    height: 400),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(13.8)),
                        if(widget.algorithm != Algorithm.hsvPositionBasedWithWiki)
                          Expanded(child: Image.asset("assets/spectrumGen.jpg"))
                        else
                          Expanded(child: Image.asset("assets/wikispectrum.png")),
                        Padding(padding: EdgeInsets.all(9.0)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(18.0)),
                    Text("Analyzed spectrum", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                    Padding(padding: EdgeInsets.all(4.0)),
                    Image.file(File(widget.imageFilePath!)),
                  ],
                );
              }
              else if(snapshot.hasError){
                return Text("Something went wrong\n" + snapshot.error.toString());
              }

               else{
                return const CircularProgressIndicator();
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