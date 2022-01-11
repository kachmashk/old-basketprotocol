import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerBanner extends StatelessWidget {
  final player;
  final color;
  final onClick;

  PlayerBanner(
      {Key key, @required this.player, @required this.color, this.onClick})
      : super(key: key);

  final textStyle = GoogleFonts.getFont(
    'Ubuntu',
    fontSize: 21,
    color: Colors.white,
    shadows: <Shadow>[
      Shadow(
        color: Colors.black,
        blurRadius: 10,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: 6,
        ),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color.withOpacity(.85),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black,
              blurRadius: 2,
              spreadRadius: 1,
            )
          ],
          border: Border.all(
            color: color.withOpacity(.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          player['name'],
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}
