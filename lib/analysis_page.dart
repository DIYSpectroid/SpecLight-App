
import 'dart:async';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spectroid/image_analysis/alogrithm_factory.dart';
import 'package:spectroid/image_analysis/analysis/spectrable.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:spectroid/image_analysis/data_extraction/image_data_extraction.dart';

import 'image_analysis/data_extraction/image_data.dart';


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

  List<charts.Series<LinearData, double>> createPlotData(Spectrable spectrable) {

    List<LinearData> data = [];
    for (double key in spectrable.spectrum.keys) {
      data.add(LinearData(key, spectrable.spectrum[key]!));
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

        title: Text(AppLocalizations.of(context)!.analysis_header),
      ),
      body: Center(
        child:
        FutureBuilder<Spectrable?>(
            future: getSpectrum(),
            builder: (BuildContext context, AsyncSnapshot<Spectrable?> snapshot) {
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
                        selectionModels: [
                          new charts.SelectionModelConfig(
                            type: charts.SelectionModelType.info,
                            changedListener: _onSelectionChanged,
                          )
                        ],
                        domainAxis: const charts.NumericAxisSpec(
                          tickProviderSpec:
                            charts.BasicNumericTickProviderSpec(zeroBound: false),
                          viewport: charts.NumericExtents(SpectrablesMetadata.WAVELENGTH_MIN, SpectrablesMetadata.WAVELENGTH_MAX))
                    ),
                    height: 400),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(13.8)),
                        // if(widget.algorithm != Algorithm.hsvPositionBasedWithWiki)
                          Expanded(child: Image.asset("assets/spectrumGen.jpg"))
                        // else
                        //   Expanded(child: Image.asset("assets/wikispectrum.png"))
                        ,
                        Padding(padding: EdgeInsets.all(9.0)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(18.0)),
                    Text("Selected x: $chosen_x, selected y: $chosen_y"),
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