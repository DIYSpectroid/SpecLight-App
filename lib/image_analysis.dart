import 'dart:io';
import 'package:image/image.dart' as img;


class ImageAnalysis{

  static List<int> getRGBABytesFromABGRInts(List<int> pixels){
    List<int> bytes = [];

    for (var element in pixels) {
      bytes.add(element % 256);
      bytes.add((element~/(256))%256);
      bytes.add((element~/(256*256))%256);
      bytes.add(element~/(256*256*256));
    }
    return bytes;
  }


  static Future<List<int>> getBytes(String imageFilePath) async{
    List<int> values = await File(imageFilePath).readAsBytes();
    img.Image image = img.decodeImage(values)!;
    return image.data;
  }
}




