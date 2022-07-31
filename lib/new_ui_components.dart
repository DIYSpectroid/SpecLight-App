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

class ImageButton extends StatelessWidget {

  final String imagePath;
  final String label;
  final void Function()? onPressed;
  final Color color;

  ImageButton({
    required this.imagePath,
    required this.label,
    this.onPressed,
    this.color = const Color(0x40D2D0E7),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Row(
        children: [
          Image(image: AssetImage(imagePath)),
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

class BottomTab extends StatefulWidget {

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  //final double size;

  BottomTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color
    //this.size = 60
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
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(bottom: 7.0)),
                Icon(widget.icon, color: widget.selected ? Colors.white : Colors.white60, size: 24),
                Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(widget.label, style: TextStyle(color: widget.selected ? Colors.white : Colors.white60, fontSize: 12),),
              ]
            ),
          onTap: (){},
        )
      )
    );
  }
}