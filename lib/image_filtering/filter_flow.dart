import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

int gaussRadius = 3;

Future<ImageData> filterFlow(String imageFilePath) async {
  List<int> values = await File(imageFilePath).readAsBytes();
  img.Image inputImage = img.decodeImage(values)!;
  img.Image gaussBlur = img.gaussianBlur(inputImage, gaussRadius);
  final png = img.encodePng(gaussBlur);
  final Directory directory = await getTemporaryDirectory();
  String path = directory.path + '/filtered.png';
  await File(path).writeAsBytes(png);
  return ImageData(
      path, gaussBlur.data, gaussBlur.height, gaussBlur.width);
}