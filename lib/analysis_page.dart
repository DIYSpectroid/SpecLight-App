
import 'dart:async';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/image_analysis/alogrithm_factory.dart';
import 'package:spectroid/image_analysis/analysis/spectrable.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data_extraction.dart';

import 'image_analysis/data_extraction/image_data.dart';
import 'numerical_analysis/find_peaks.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final ImagePicker picker = ImagePicker();

class AnalysisPage extends StatefulWidget{

  const AnalysisPage({Key? key, required this.imageFilePath, required this.algorithm, required this.grating}) : super(key: key);

  final String? imageFilePath;
  final Algorithm algorithm;
  final Grating grating;

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

  List<LinearData> createPlotData(Spectrable spectrable) {
    List<LinearData> data = [];
    for (double key in spectrable.spectrum.keys) {
      data.add(LinearData(key, spectrable.spectrum[key]!));
    }
    data.sort((e1,e2) => e1.x.compareTo(e2.x));
    return data;
  }

  Future<Spectrable?> getSpectrum() async{
    ImageData imageData = await compute(ImageDataExtraction.getImageData, widget.imageFilePath!);
    await imageData.extractData();

    print(imageData.width);

    Spectrable? spectrumGenerator = AlgorithmFactory()
        .setAlgorithm(widget.algorithm)
        .setGrating(widget.grating)
        .setImageData(imageData)
        .create();

    if(spectrumGenerator == null) {
      throw new Exception("Something went wrong");
    }
    spectrumGenerator.generateSpectrum();
    return spectrumGenerator;
  }

  double chosen_x = 0;
  double chosen_y = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.analysis_header, style: TextStyle(color: Colors.white),),
        leading: const BackButton(
          color: Colors.white,
        )
      ),
      body: Center(
        child:
        FutureBuilder<Spectrable?>(
            future: getSpectrum(),
            builder: (BuildContext context, AsyncSnapshot<Spectrable?> snapshot) {
              if(snapshot.hasData){
                List<LinearData> seriesList = createPlotData(snapshot.data!);
                List<LinearData> peaks = FindPeaks(seriesList, 20, double.infinity, 20, 1);
                //List<double> sortedWavelength = spectrum.spectrum.keys.toList();
                //sortedWavelength.sort((a, b) => a.compareTo(b));
                //FindPeaks(snapshot.data!.spectrum, 5, double.infinity).forEach((element) {print("Extreme at x: ${element.x}, with y: ${element.y}"); });
                return
                ListView(
                  children: [
                    Container(
                    child: SfCartesianChart(
                        palette: <Color>[
                          Theme.of(context).accentColor,
                          Theme.of(context).primaryColor
                        ],
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 100,
                          visibleMaximum: 109,
                          maximumLabels: 5
                        ),
                        primaryXAxis: NumericAxis(
                            visibleMinimum: SpectrablesMetadata.WAVELENGTH_MIN.toDouble(),
                            visibleMaximum: SpectrablesMetadata.WAVELENGTH_MAX.toDouble(),
                        ),
                        series: <ChartSeries>[
                          // Renders line chart
                          LineSeries<LinearData, double>(
                              dataSource: seriesList,
                              xValueMapper: (LinearData data, _) => data.x,
                              yValueMapper: (LinearData data, _) => data.y
                          ),
                          ScatterSeries<LinearData, double>(
                              animationDelay: 2000,
                              dataSource: peaks,
                              xValueMapper: (LinearData data, _) => data.x,
                              yValueMapper: (LinearData data, _) => data.y,
                              markerSettings: MarkerSettings(
                                  height: 10,
                                  width: 10,
                                  // Scatter will render in diamond shape
                                  shape: DataMarkerType.diamond
                              )
                          )
                        ],
                    ),
                    height: 400, width: 100, padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: 36)),
                        Expanded(child: Image.asset("assets/spectrumGen.jpg")),
                        Padding(padding: EdgeInsets.only(left: 30)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(18.0)),
                    Text(AppLocalizations.of(context)!.analyzed_spectrum, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                    Padding(padding: EdgeInsets.all(4.0)),
                    Container(child: Image.file(File(widget.imageFilePath!)), height: 200,),
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