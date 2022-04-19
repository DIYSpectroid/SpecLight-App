import 'package:flutter/material.dart';

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
          Expanded(child: Container(
            height: 30,
          ),),
          Text(label, style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Franklin'), textAlign: TextAlign.center,),
          Expanded(child: Container(
            height: 30,
          ),),
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
