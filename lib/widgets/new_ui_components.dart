import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuButton extends StatelessWidget {

  final IconData icon;
  final String label;
  final void Function()? onPressed;
  final Color color;

  MenuButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color = const Color(0x40D2D0E7),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          Text(label, style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Franklin'), textAlign: TextAlign.center,),
        ],
      ),
      style: ButtonStyle(
          shape:
          MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
              )
          ),
          backgroundColor: MaterialStateProperty.all(color),

      ),
      onPressed: onPressed,
    );
  }
}

class ImageButton extends StatelessWidget {

  final String imagePath;
  final double imageSize;
  final String label;
  final void Function()? onPressed;
  final Color color;

  ImageButton({
    required this.imagePath,
    required this.imageSize,
    required this.label,
    this.onPressed,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Row(
        children: [
          SizedBox(width: imageSize, height: imageSize, child: Image(image: AssetImage(imagePath))),
          Expanded(child: Container(height: 50)),
          Text(label, style: TextStyle(color: color, fontSize: 14), textAlign: TextAlign.center,),
          Expanded(child: Container(height: 50)),
        ],
      ),
      onPressed: onPressed,
    );
  }
}

class SquareButton extends StatelessWidget {

  final IconData icon;
  final String label;
  final void Function()? onPressed;
  final Color color;
  final double size;

  SquareButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color = const Color(0x40D2D0E7),
    this.size = 60
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [TextButton(
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            children: [
              Expanded(child: Container()),
              Icon(icon, color: Colors.black, size: 40),
              Expanded(child: Container())
            ],
          ),
        ),
        style: ButtonStyle(
          shape:
          MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              )
          ),
          backgroundColor: MaterialStateProperty.all(color),

        ),
        onPressed: onPressed,
      ),
        Padding(padding: EdgeInsets.all(5)),
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16),),
      ]
    );
  }
}

class BottomTab extends StatefulWidget {

  final IconData icon;
  final String label;
  final int id;
  ValueNotifier<int> currentID;
  final Color color;
  final void Function()? onPressed;

  BottomTab({
    required this.icon,
    required this.label,
    required this.id,
    required this.currentID,
    required this.color,
    this.onPressed
  });

  @override
  State<StatefulWidget> createState() {
    return _BottomTabState();
  }
}

class _BottomTabState extends State<BottomTab> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: widget.color,
         child: InkWell(
            child: ValueListenableBuilder<int>(
              valueListenable: widget.currentID,
              builder: (context, value, _){
                return Column(
                  children: [
                    Padding(padding: EdgeInsets.only(bottom: 7.0)),
                    Icon(widget.icon, color: widget.id == value ? Colors.white : Colors.white60, size: 24),
                    Padding(padding: EdgeInsets.only(bottom: 2.0)),
                    Text(widget.label, style: TextStyle(color: widget.id == value ? Colors.white : Colors.white60, fontSize: 12),),
                  ]
                );
            }
           ),
          onTap: (){
              if(widget.onPressed != null && widget.currentID.value != widget.id){
                widget.onPressed!();
              }
              setState(() {
                widget.currentID.value = widget.id;
              });
          },
        )
      )
    );
  }
}