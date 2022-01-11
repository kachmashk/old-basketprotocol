import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

Flushbar<bool> buildCustomFlushbar(
    String _playerName,
    String _message,
    int _duration,
    AnimationController _progressController,
    Function _onIconClick) {
  return Flushbar<bool>(
    messageText: Text(
      '$_playerName: $_message',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    margin: const EdgeInsets.symmetric(vertical: 35, horizontal: 60),
    padding: const EdgeInsets.all(4),
    forwardAnimationCurve: Curves.ease,
    reverseAnimationCurve: Curves.ease,
    flushbarStyle: FlushbarStyle.FLOATING,
    flushbarPosition: FlushbarPosition.TOP,
    borderRadius: 4,
    backgroundColor: Colors.black.withOpacity(.9),
    mainButton: IconButton(
      icon: Icon(Icons.undo),
      color: Colors.white,
      onPressed: _onIconClick,
    ),
    showProgressIndicator: true,
    progressIndicatorController: _progressController,
    progressIndicatorBackgroundColor: Colors.blueGrey,
    duration: Duration(seconds: _duration),
    isDismissible: true,
  );
}
