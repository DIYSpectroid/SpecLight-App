
import 'dart:async';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectroid/image_analysis/alogrithm_factory.dart';
import 'package:spectroid/image_analysis/analysis/spectrable.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data_extraction.dart';
import 'package:spectroid/image_filtering/filter_flow.dart';


import '../analysis_page_components.dart';
import '../image_analysis/data_extraction/image_data.dart';
import '../numerical_analysis/compare_peaks.dart';
import '../numerical_analysis/find_peaks.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'overview.dart';

final ImagePicker picker = ImagePicker();

bool filtering = false;

class AnalysisPage extends StatefulWidget{

  const AnalysisPage({Key? key, required this.imageFilePath, required this.algorithm, required this.grating, required this.prefs}) : super(key: key);

  final String? imageFilePath;
  final Algorithm algorithm;
  final Grating grating;
  final SharedPreferences prefs;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();

}

class ProgressProvider extends ChangeNotifier {
  String _processingState = "";

  String get processingState => _processingState;

  set processingState (String newState) {
    _processingState = newState;
    notifyListeners();
  }
}

class _AnalysisPageState extends State<AnalysisPage> {
  Future<ImageData>? imageData;
  File? imageFile;
  ProgressProvider provider = ProgressProvider();


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
    provider.processingState = "Extracting image data";
    ImageData imageData;
    if(filtering)
    {
      imageData = await filterFlow((widget.imageFilePath!));
    }
    else
    {
      imageData = await compute(ImageDataExtraction.getImageData, widget.imageFilePath!);
    }
    await imageData.extractData();
    provider.processingState = "Analyzing spectrum";
    Spectrable? spectrumGenerator = AlgorithmFactory()
        .setAlgorithm(widget.algorithm)
        .setGrating(widget.grating)
        .setImageData(imageData)
        .create();
    if(spectrumGenerator == null) {
      throw new Exception("Something went wrong");
    }
    await spectrumGenerator.generateSpectrum();
    return spectrumGenerator;
  }

  double chosen_x = 0;
  double chosen_y = 0;

  late TooltipBehavior _tooltipBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  Widget build(BuildContext context) {

    _tooltipBehavior = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series,
            int pointIndex, int seriesIndex) {
          return CustomTooltip(y: point.y, x: point.x, peak: AppLocalizations.of(context)!.peak, intensity: AppLocalizations.of(context)!.intensity, wavelength: AppLocalizations.of(context)!.wavelength);
        }
    );

    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
        enable: true,
        tooltipAlignment: ChartAlignment.center,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        builder: (BuildContext context, TrackballDetails trackballDetails) {
          return CustomTrackball(y: trackballDetails.groupingModeInfo?.points[0].yValue, x: trackballDetails.groupingModeInfo?.points[0].xValue, intensity: AppLocalizations.of(context)!.intensity, wavelength: AppLocalizations.of(context)!.wavelength);
        }

    );

    List<String> categories = <String>[AppLocalizations.of(context)!.category0, AppLocalizations.of(context)!.category1];
    return ChangeNotifierProvider(create: (context) => provider,
      child: Scaffold(
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
                List<LinearData> peaks;
                if(widget.grating == Grating.grating0) {
                  peaks = FindPeaks(
                      seriesList, 0, double.infinity, 0, 0);
                }
                else
                {
                  peaks = FindPeaks(
                      seriesList, 2, double.infinity, 2, 0);
                }
                //List<double> sortedWavelength = spectrum.spectrum.keys.toList();
                //sortedWavelength.sort((a, b) => a.compareTo(b));
                //FindPeaks(snapshot.data!.spectrum, 5, double.infinity).forEach((element) {print("Extreme at x: ${element.x}, with y: ${element.y}"); });
                return
                ListView(
                  children: [
                    Container(
                    child: SfCartesianChart(
                      trackballBehavior: _trackballBehavior,
                      tooltipBehavior: _tooltipBehavior,
                        palette: <Color>[
                          Theme.of(context).hintColor,
                          Theme.of(context).primaryColor
                        ],
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 100,
                          visibleMaximum: 109,
                          maximumLabels: 5,
                          decimalPlaces: 1
                        ),
                        primaryXAxis: NumericAxis(
                            visibleMinimum: SpectrablesMetadata.WAVELENGTH_MIN.toDouble(),
                            visibleMaximum: SpectrablesMetadata.WAVELENGTH_MAX.toDouble(),
                            decimalPlaces: 1,
                        ),
                        series: <ChartSeries>[
                          // Renders line chart
                          LineSeries<LinearData, double>(
                              dataSource: seriesList,
                              xValueMapper: (LinearData data, _) => data.x,
                              yValueMapper: (LinearData data, _) => data.y,
                               enableTooltip: false,


                          ),
                          ScatterSeries<LinearData, double>(
                              animationDelay: 150,
                              dataSource: peaks,
                              xValueMapper: (LinearData data, _) => data.x,
                              yValueMapper: (LinearData data, _) => data.y,
                              markerSettings: MarkerSettings(
                                  height: 10,
                                  width: 10,
                                  // Scatter will render in diamond shape
                                  shape: DataMarkerType.diamond
                              ),
                              enableTooltip: true,
                          )
                        ],
                    ),
                    height: 400, width: 100, padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: 36)),
                        Expanded(
                            child: Image(
                                image: AssetImage("assets/Spectrum_iod.png"),
                                fit: BoxFit.fill,
                                height: 35,
                            )
                        ),
                        Padding(padding: EdgeInsets.only(left: 30)),
                      ],
                    ),
                    Container(child: Divider(color: Colors.black54), padding: EdgeInsets.fromLTRB(30, 5, 30, 5)),
                    Text(AppLocalizations.of(context)!.analyzed_spectrum, textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
                    Padding(padding: EdgeInsets.all(4.0)),
                    Container(child: Image.file(File(snapshot.data!.imageData.filepath)),),
                    Container(child: Divider(color: Colors.black54), padding: EdgeInsets.fromLTRB(30, 5, 30, 5)),
                    Text(AppLocalizations.of(context)!.closest_match, textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
                    Padding(padding: EdgeInsets.all(4.0)),
                    FutureBuilder(

                      future: ComputePeaks({'peaks': peaks, 'prefs': widget.prefs}),
                      builder: (BuildContext context, AsyncSnapshot<List<CompareResult>> snapshot) {
                        if(snapshot.hasData)
                        {
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  margin: EdgeInsets.fromLTRB(50, 0, 50, 20),
                                  child: InkWell(
                                    splashColor:
                                    Theme.of(context).hintColor.withAlpha(30),
                                    //ADD ON PRESS
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => OverviewPage(index: snapshot.data![index].result, prefs: widget.prefs)),
                                      );
                                    },
                                    child:
                                    Row(
                                      children: [
                                        Expanded(child: Container(height: 10,)),
                                        Column(
                                          children: [
                                            Text(AppLocalizations.of(context)!.error, style: TextStyle(fontSize: 14, color: Colors.black54)),
                                            Text(snapshot.data![index].accuracy.toString(), style: TextStyle(fontSize: 20, color: Colors.black)),
                                          ]
                                        ),
                                        Expanded(child: Container(height: 10,)),
                                        Column(
                                          children: [
                                            Container(height: 10),
                                            Image.asset(snapshot.data![index].photo, height: 80),
                                            Container(height: 5),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                              child: Align(
                                                  child: Text(snapshot.data![index].name,
                                                      style: TextStyle(fontSize: 20, color: Colors.black)),
                                                  alignment: Alignment.centerLeft),
                                            ),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0),
                                              child: Align(
                                                  child: Text(
                                                      categories[snapshot.data![index].category],
                                                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                                                  alignment: Alignment.centerLeft),
                                            ),
                                            Container(height: 10)
                                          ],
                                        ),
                                        Container(width: 10)
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                        else if(snapshot.hasError){
                        return Text(AppLocalizations.of(context)!.error_message + "\n" + snapshot.error.toString());
                        }
                        else{
                        return SizedBox(width: 100, height: 100, child: const CircularProgressIndicator());
                        }
                      }
                    )
                  ],
                );
              }
              else if(snapshot.hasError){
                return Text(AppLocalizations.of(context)!.error_message + "\n" + snapshot.error.toString());
              }

               else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/HexagonRotating.json', width: 150, height: 150),
                      Container(height: 30),
                      Consumer<ProgressProvider>(builder: (context, user, _) => Text(user.processingState, style: TextStyle(color: Colors.black, fontSize: 20)))
                    ]
                  )
                );
              }
            }
        ),
        ),
      )
    );
  }
}

class LinearData {
  final double x;
  final double y;

  LinearData(this.x, this.y);
}