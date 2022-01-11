import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final onClick;
  final label;
  final margin;
  final padding;
  final color;
  final isFlatButtonWanted;

  CustomButton(
      {@required Key key,
      @required this.onClick,
      @required this.label,
      this.margin,
      this.padding,
      this.color,
      this.isFlatButtonWanted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin != null ? margin : const EdgeInsets.all(1),
      padding: padding != null ? padding : const EdgeInsets.all(1),
      child:
          isFlatButtonWanted == true ? buildFlatButton() : buildRaisedButton(),
    );
  }

  Widget buildFlatButton() {
    return FlatButton(
      onPressed: onClick,
      child: Text(
        label,
        style: GoogleFonts.getFont(
          'Ubuntu',
          fontSize: 16,
          letterSpacing: 1,
          color: Color.fromRGBO(0, 155, 200, 1),
          shadows: <Shadow>[
            Shadow(color: Colors.black, blurRadius: .5),
          ],
        ),
      ),
    );
  }

  Widget buildRaisedButton() {
    return RaisedButton(
      onPressed: onClick,
      color: color != null ? color : Color.fromRGBO(30, 150, 225, 1),
      child: Text(
        label,
        style: GoogleFonts.getFont(
          'Ubuntu',
          textStyle: TextStyle(
            fontSize: 16,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                color: Colors.black,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
