import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeInAnimation extends StatelessWidget {
  final Curve curve;
  final double delay;
  final Widget child;
  final int opacityMilliseconds;
  final double transitionXBegin;

  FadeInAnimation(
      {Key key,
      @required this.delay,
      @required this.transitionXBegin,
      @required this.curve,
      @required this.child,
      this.opacityMilliseconds = 800});

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween(
      [
        Track("opacity").add(
          Duration(
            milliseconds: opacityMilliseconds,
          ),
          Tween(
            begin: 0.0,
            end: 1.0,
          ),
        ),
        Track("translateX").add(
          Duration(milliseconds: 750),
          Tween(
            begin: transitionXBegin,
            end: 0.0,
          ),
          curve: curve,
        ),
      ],
    );

    return ControlledAnimation(
      delay: Duration(
        milliseconds: delay.round(),
      ),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
          offset: Offset(animation["translateX"], 0),
          child: child,
        ),
      ),
    );
  }
}
