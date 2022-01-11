import 'package:flutter/material.dart';

import 'package:basket_protocol/core/helpers/date_time_parser.dart';

class Contest {
  String _id;

  String _venue;
  String _title;

  int _throwsPerZone;

  var _duration = '0 minutes';

  List<Map<String, dynamic>> _players;
  List<Map<String, dynamic>> _overtimePlayers;

  bool _isFinished = false;

  String get id => this._id;
  set id(String _id) => this._id = _id;

  String get venue => this._venue;
  String get title => this._title;
  String get duration => this._duration;

  int get throwsPerZone => this._throwsPerZone;

  bool get isFinished => this._isFinished;

  List<Map<String, dynamic>> get players => this._players;
  List<Map<String, dynamic>> get overtimePlayers => this._overtimePlayers;

  Map<String, dynamic> get map {
    return {
      'id': this._id,
      'duration': this._duration,
      'isFinished': this._isFinished,
      'players': this._players,
      'overtimePlayers': this._overtimePlayers
    };
  }

  Contest(
      {@required int throwsPerZone,
      @required List<Map<String, dynamic>> players,
      String id,
      String venue,
      String title,
      bool isFinished,
      List<Map<String, dynamic>> overtimePlayers}) {
    this._throwsPerZone = throwsPerZone ?? this._throwsPerZone;
    this._players = players ?? this._players;

    this._id = id ?? this._id;
    this._venue = venue ?? this._venue;
    this._title = title ?? this._title;
    this._isFinished = isFinished ?? this._isFinished;
    this._overtimePlayers = overtimePlayers ?? this._overtimePlayers;

    if (title == null) {
      this._title = '$_venue - ${DateTimeParser.getDateTimeNowString()}';
    }
  }

  void update(Map<String, dynamic> _contestData) {
    this._isFinished = _contestData['isFinished'] ?? this._isFinished;

    this._players = _contestData['players'] ?? this._players;
    this._overtimePlayers =
        _contestData['overtimePlayers'] ?? this._overtimePlayers;

    this._duration =
        DateTimeParser.updateActivityDuration(this._title.split(' - ')[1]);
  }
}
