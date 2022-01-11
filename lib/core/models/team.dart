import 'package:flutter/material.dart';

class Team {
  String _name;
  int _points = 0;
  List<Map<String, dynamic>> _players;

  String get name => _name;
  int get points => _points;
  List<Map<String, dynamic>> get players => _players;

  Team({@required name, @required players}) {
    this._name = name ?? this._name;
    this._players = players ?? this._players;

    for (final _player in players) {
      this._points += _player['twoPointsMade'] * 2;
      this._points += _player['threePointsMade'] * 3;
    }
  }

  void update(List<Map<String, dynamic>> _players) {
    this._points = 0;

    for (final _player in _players) {
      this._points += _player['twoPointsMade'] * 2;
      this._points += _player['threePointsMade'] * 3;
    }

    this._players = _players;
  }
}
