import 'package:flutter/material.dart';

import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/helpers/date_time_parser.dart';

class Match {
  String _id;

  String _title;
  String _venue;
  String _gameRule;
  String _gameMode;

  var _duration = '0 minutes';
  var _isFinished = false;

  int _gameRuleValue;
  int _quarterNr;
  int _overtimeNr;

  Team _teamOne;
  Team _teamTwo;

  String get id => this._id;
  set id(String _id) => this._id = _id;

  String get title => this._title;
  String get duration => this._duration;
  String get venue => this._venue;
  String get gameRule => this._gameRule;
  String get gameMode => this._gameMode;

  int get gameRuleValue => this._gameRuleValue;
  int get quarterNr => this._quarterNr;
  int get overtimeNr => this._overtimeNr;

  bool get isFinished => this._isFinished;

  Team get teamOne => this._teamOne;
  Team get teamTwo => this._teamTwo;

  Map<String, dynamic> get map {
    return {
      'id': _id,
      'quarterNr': _quarterNr,
      'overtimeNr': _overtimeNr,
      'isFinished': _isFinished,
      'duration': _duration,
      'teamOne': ({
        'name': _teamOne.name,
        'points': _teamOne.points,
        'players': _teamOne.players
      }),
      'teamTwo': ({
        'name': _teamTwo.name,
        'points': _teamTwo.points,
        'players': _teamTwo.players
      })
    };
  }

  Match(
      {@required String gameRule,
      @required String gameMode,
      @required int gameRuleValue,
      @required Team teamOne,
      @required Team teamTwo,
      String id,
      String venue,
      String title,
      int quarterNr,
      int overtimeNr,
      bool isFinished}) {
    this._id = id;
    this._venue = venue;

    this._gameRule = gameRule;
    this._gameMode = gameMode;
    this._gameRuleValue = gameRuleValue;

    this._teamOne = teamOne;
    this._teamTwo = teamTwo;

    this._title = title;
    this._quarterNr = quarterNr;
    this._overtimeNr = overtimeNr;

    this._isFinished = isFinished ?? this._isFinished;

    this._quarterNr = quarterNr ?? 1;
    this._overtimeNr = overtimeNr ?? 0;

    this._title = title ?? '$_venue - ${DateTimeParser.getDateTimeNowString()}';
  }

  void update(Map<String, dynamic> _matchData) {
    this._id = _matchData['id'] ?? this._id;
    this._isFinished = _matchData['isFinished'] ?? this._isFinished;
    this._quarterNr = _matchData['quarterNr'] ?? this._quarterNr;
    this._overtimeNr = _matchData['overtimeNr'] ?? this._overtimeNr;

    if (_matchData['teamOne'] != null) {
      this._teamOne.update(_matchData['teamOne']['players']);
    }

    if (_matchData['teamTwo'] != null) {
      this._teamTwo.update(_matchData['teamTwo']['players']);
    }

    this._duration =
        DateTimeParser.updateActivityDuration(this._title.split(' - ')[1]);
  }
}
