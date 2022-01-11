import 'package:flutter_test/flutter_test.dart';

import 'package:basket_protocol/core/helpers/tables_counters.dart';

import '../../mocks/mock_players.dart';

void main() {
  var _player = MockPlayers.getUpdatedPlayer();

  group('contest table counters ->', () {
    test('should return string \'scored / total throws\'', () {
      final _result = TablesCounters.throwsTotal(_player);

      expect(int.parse(_result.split('/')[0]), equals(_player['scored']));
      expect(int.parse(_result.split('/')[1]),
          equals(_player['scored'] + _player['missed']));
    });

    test('should return string percentage of \'scored / total throws\'', () {
      final _result = TablesCounters.throwsTotalPercentage(_player);
      final _percentage =
          _player['scored'] / (_player['scored'] + _player['missed']) * 100;

      expect(_result, matches('${_percentage.toString().split('.')[0]}%'));
    });
  });

  group('match table counters ->', () {
    test('should return string \'two pointers made / two pointers attempts\'',
        () {
      final _result = TablesCounters.twoPointersTotal(_player);

      final _twoPointsMade = int.parse(_result.split('/')[0]);
      final _twoPointsAttempts = int.parse(_result.split('/')[1]);

      expect(_twoPointsMade, equals(_player['twoPointsMade']));
      expect(_twoPointsAttempts, equals(_player['twoPointsAttempts']));
    });

    test('should return 0% for two pointers', () {
      final _tempPlayer = <String, dynamic>{
        'twoPointsMade': 0,
        'twoPointsAttempts': 0
      };

      final _result = TablesCounters.twoPointersPercentageTotal(_tempPlayer);

      expect(_result, matches('0%'));
    });

    test(
        'should return string percentage \'two pointers made / two pointers made attempts\'',
        () {
      final _result = TablesCounters.twoPointersPercentageTotal(_player);

      final _percentage =
          _player['twoPointsMade'] / _player['twoPointsAttempts'] * 100;

      expect(_result, matches('${_percentage.toString().split('.')[0]}%'));
    });

    test(
        'should return string \'three pointers made / three pointers attempts\'',
        () {
      final _result = TablesCounters.threePointersTotal(_player);

      final _threePointsMade = int.parse(_result.split('/')[0]);
      final _threePointsAttempts = int.parse(_result.split('/')[1]);

      expect(_threePointsMade, equals(_player['threePointsMade']));
      expect(_threePointsAttempts, equals(_player['threePointsAttempts']));
    });

    test('should return 0% for three pointers', () {
      final _tempPlayer = <String, dynamic>{
        'threePointsMade': 0,
        'threePointsAttempts': 0
      };

      final _result = TablesCounters.threePointersPercentageTotal(_tempPlayer);

      expect(_result, matches('0%'));
    });

    test(
        'should return string percentage \'three pointers made / three pointers made attempts\'',
        () {
      final _result = TablesCounters.threePointersPercentageTotal(_player);

      final _percentage =
          _player['threePointsMade'] / _player['threePointsAttempts'] * 100;

      expect(_result, matches('${_percentage.toString().split('.')[0]}%'));
    });

    test('should return string \'field goals made / field goals attempts\'',
        () {
      final _result = TablesCounters.fieldGoalsTotal(_player);

      final _fieldGoalsMade =
          _player['twoPointsMade'] + _player['threePointsMade'];
      final _fieldGoalsAttempts =
          _player['twoPointsAttempts'] + _player['threePointsAttempts'];

      expect(int.parse(_result.split('/')[0]), equals(_fieldGoalsMade));
      expect(int.parse(_result.split('/')[1]), equals(_fieldGoalsAttempts));
    });

    test('should return 0% for field goals', () {
      final _tempPlayer = <String, dynamic>{
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      };

      final _result = TablesCounters.fieldGoalsPercentageTotal(_tempPlayer);

      expect(_result, matches('0%'));
    });

    test(
        'should return string percentage \'field goals made / field goals made attempts\'',
        () {
      final _result = TablesCounters.fieldGoalsPercentageTotal(_player);

      final _fieldGoalsMade =
          _player['twoPointsMade'] + _player['threePointsMade'];
      final _fieldGoalsAttempts =
          _player['twoPointsAttempts'] + _player['threePointsAttempts'];

      final _percentage = _fieldGoalsMade / _fieldGoalsAttempts * 100;

      expect(_result, matches('${_percentage.toString().split('.')[0]}%'));
    });
  });
}
