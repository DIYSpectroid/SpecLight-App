import 'package:flutter/material.dart';

class CustomTooltip extends StatelessWidget {

  final double y;
  final double x;
  String peak;
  String intensity;
  String wavelength;

  CustomTooltip({
    required this.y,
    required this.x,
    required this.peak,
    required this.intensity,
    required this.wavelength
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFA7921),
      height: 80,
      width: 150,
      child: Column(
        children: [
          Expanded(child: Container(width: 150,)),
          Text(peak, style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(
              width: 140, child: Divider(color: Colors.white, thickness: 1)),
          Text(intensity + ": " + y.toStringAsFixed(1) + "%",
              style: TextStyle(color: Colors.white)),
          SizedBox(height: 2,),
          Text(wavelength + ": " + x.toStringAsFixed(1) + "nm",
            style: TextStyle(color: Colors.white),),
          Expanded(child: Container(width: 150,)),
        ],
      ),
    );
  }
}

class CustomTrackball extends StatelessWidget {

  final double y;
  final double x;
  String intensity;
  String wavelength;


  CustomTrackball({
    required this.y,
    required this.x,
    required this.intensity,
    required this.wavelength
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFA7921),
      height: 50,
      width: 150,
      child: Column(
        children: [
          Expanded(child: Container(width: 150,)),
          Text(intensity + ": " + y.toStringAsFixed(1)  + "%", style: TextStyle(color: Colors.white)),
          Expanded(child: Container(width: 150,)),
          Text(wavelength + ": " + x.toStringAsFixed(1) + "nm", style: TextStyle(color: Colors.white),),
          Expanded(child: Container(width: 150,)),
        ],
      ),
    );
  }
}