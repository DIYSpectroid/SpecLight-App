import 'package:url_launcher/url_launcher.dart';

void openUrl (String url) async{
  LaunchMode launchMode = LaunchMode.externalApplication;
  Uri urlParsed = Uri.parse(url);
  if (await canLaunchUrl(urlParsed)) {
  await launchUrl(urlParsed, mode: launchMode);
  } else {
  throw 'Could not launch $url';
  }
}