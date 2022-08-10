
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/image_analysis.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:spectroid/image_data_extraction.dart';
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

  List<LinearData> createPlotData(Spectrum spectrum) {

    List<LinearData> data = [];
    for (double key in spectrum.getKeys()) {
      data.add(LinearData(key, spectrum.spectrum[key]!));
    }
    data.sort((e1,e2) => e1.x.compareTo(e2.x));
    return data;
  }

  Future<Spectrum> getSpectrum() async{
    ImageData imageData = await analyzeImage();
    List<int> rgba = await compute(ImageDataExtraction.getRGBABytesFromABGRInts, imageData.bytes);
    List<HSVPixel> hsvPixels =  await compute(ImageDataExtraction.convertBytesToHSV, rgba);
    List<RGBPixel> rgbPixels = await compute(ImageDataExtraction.convertBytesToRGB, rgba);

    Spectrum spectrum = Spectrum(hsvPixels, imageData.width, imageData.height, rgbPixels, widget.algorithm, widget.grating);
    return spectrum;
  }

  double chosen_x = 0;
  double chosen_y = 0;

  _onSelectionChanged(charts.SelectionModel model){
    final selectedDatum = model.selectedDatum;
    double x = 0;
    double y = 0;
    print('test');
    if (selectedDatum.isNotEmpty) {
       x = selectedDatum.first.datum.x;
       y = selectedDatum.last.datum.y;
    }

    setState(() {chosen_x = x; chosen_y = y;});
  }

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
        FutureBuilder<Spectrum>(
            future: getSpectrum(),
            builder: (BuildContext context, AsyncSnapshot<Spectrum?> snapshot) {
              if(snapshot.hasData){
                List<LinearData> seriesList = createPlotData(snapshot.data!);
                //List<double> sortedWavelength = spectrum.spectrum.keys.toList();
                //sortedWavelength.sort((a, b) => a.compareTo(b));
                return
                ListView(
                  children: [
                    Container(
                    child: SfCartesianChart(
                        palette: <Color>[
                          Theme.of(context).accentColor
                        ],
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value}%',
                          visibleMinimum: 0,
                          visibleMaximum: 100
                        ),
                        primaryXAxis: NumericAxis(
                            visibleMinimum: Spectrum.wavelengthMin.toDouble(),
                            visibleMaximum: Spectrum.wavelengthMax.toDouble(),
                        ),
                        series: <ChartSeries>[
                          // Renders line chart
                          LineSeries<LinearData, double>(
                              dataSource: seriesList,
                              xValueMapper: (LinearData data, _) => data.x,
                              yValueMapper: (LinearData data, _) => data.y
                          ),
                          /*ScatterSeries<LinearData, double>(
                              dataSource: seriesList,
                              xValueMapper: (LinearData data, _) => data.x,
                              yValueMapper: (LinearData data, _) => data.y
                          )*/
                        ],
                        /*domainAxis: const charts.NumericAxisSpec(
                          tickProviderSpec:
                            charts.BasicNumericTickProviderSpec(zeroBound: false),
                          viewport: charts.NumericExtents(Spectrum.wavelengthMin, Spectrum.wavelengthMax))*/
                    ),
                    height: 400, width: 100, padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: 47)),
                        if(widget.algorithm != Algorithm.hsvPositionBasedWithWiki)
                          Expanded(child: Image.asset("assets/spectrumGen.jpg"))
                        else
                          Expanded(child: Image.asset("assets/wikispectrum.png")),
                        Padding(padding: EdgeInsets.only(left: 30)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(18.0)),
                    Text(AppLocalizations.of(context)!.analyzed_spectrum, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
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