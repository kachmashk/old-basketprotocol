class TablesCounters {
  static String throwsTotal(final _player) {
    final _allZonesScored = _player['scored'];
    final _allZonesMissed = _player['missed'];
    final _totalThrows = _allZonesScored + _allZonesMissed;

    return '${_allZonesScored.toString()}/${_totalThrows.toString()}';
  }

  static String throwsTotalPercentage(final _player) {
    final _allZonesScored = _player['scored'];
    final _allZonesMissed = _player['missed'];
    final _totalThrows = _allZonesScored + _allZonesMissed;

    final _result = (_allZonesScored / _totalThrows) * 100;

    return '${_result.toString().split('.')[0]}%';
  }

  static String twoPointersTotal(final _player) {
    final _twoPointsMade = _player['twoPointsMade'];
    final _twoPointsAttempts = _player['twoPointsAttempts'];

    return '${_twoPointsMade.toString()}/${_twoPointsAttempts.toString()}';
  }

  static String twoPointersPercentageTotal(final _player) {
    final _twoPointsMade = _player['twoPointsMade'];
    final _twoPointsAttempts = _player['twoPointsAttempts'];

    if (_twoPointsMade == 0 && _twoPointsAttempts == 0) return '0%';

    final _percentage = (_twoPointsMade / _twoPointsAttempts) * 100;

    return '${_percentage.toString().split('.')[0]}%';
  }

  static String threePointersTotal(final _player) {
    final _threePointsMade = _player['threePointsMade'];
    final _threePointsAttempts = _player['threePointsAttempts'];

    return '${_threePointsMade.toString()}/${_threePointsAttempts.toString()}';
  }

  static String threePointersPercentageTotal(final _player) {
    final _threePointsMade = _player['threePointsMade'];
    final _threePointsAttempts = _player['threePointsAttempts'];

    if (_threePointsMade == 0 && _threePointsAttempts == 0) return '0%';

    final _percentage = (_threePointsMade / _threePointsAttempts) * 100;

    return '${_percentage.toString().split('.')[0]}%';
  }

  static String fieldGoalsTotal(final _player) {
    final _twoPointsMade = _player['twoPointsMade'];
    final _twoPointsAttempts = _player['twoPointsAttempts'];

    final _threePointsMade = _player['threePointsMade'];
    final _threePointsAttempts = _player['threePointsAttempts'];

    final _fieldGoalsMade = _twoPointsMade + _threePointsMade;
    final _fieldGoalsAttempts = _twoPointsAttempts + _threePointsAttempts;

    return '${_fieldGoalsMade.toString()}/${_fieldGoalsAttempts.toString()}';
  }

  static String fieldGoalsPercentageTotal(final _player) {
    final _twoPointsMade = _player['twoPointsMade'];
    final _twoPointsAttempts = _player['twoPointsAttempts'];

    final _threePointsMade = _player['threePointsMade'];
    final _threePointsAttempts = _player['threePointsAttempts'];

    final _fieldGoalsMade = _twoPointsMade + _threePointsMade;
    final _fieldGoalsAttempts = _twoPointsAttempts + _threePointsAttempts;

    if (_fieldGoalsMade == 0 && _fieldGoalsAttempts == 0) return '0%';

    final _percentage = (_fieldGoalsMade / _fieldGoalsAttempts) * 100;

    return '${_percentage.toString().split('.')[0]}%';
  }
}
