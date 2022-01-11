import 'package:flutter_test/flutter_test.dart';

import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/core/helpers/date_time_parser.dart';

import '../../mocks/mock_players.dart';

void main() {
  final _players = MockPlayers.getStarterPlayersA();
  final _updatedPlayers = MockPlayers.getUpdatedPlayersA();

  final _overtimePlayers = MockPlayers.getStarterPlayersB();
  final _updatedOvertimePlayers = MockPlayers.getUpdatedPlayersB();

  final _contest = Contest(venue: 'venue', throwsPerZone: 5, players: _players);

  group('contest model ->', () {
    test('verify contest\'s fields', () {
      expect(_contest.id, isNull);
      expect(_contest.isFinished, isFalse);

      expect(_contest.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_contest.duration, matches('0 minutes'));

      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));

      expect(_contest.players, containsAllInOrder(_players));
      expect(_contest.overtimePlayers, isNull);
    });

    test('verify map getter', () {
      expect(_contest.map['id'], isNull);
      expect(_contest.map['isFinished'], isFalse);

      expect(_contest.map['duration'], matches('0 minutes'));

      expect(_contest.map['players'], containsAllInOrder(_players));
      expect(_contest.map['overtimePlayers'], isNull);
    });

    test('set contest\'s id', () {
      _contest.id = 'FeArey7LgeX9IOAkWsxAQc1gEs33';

      expect(_contest.id, matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));
    });

    test('update contest as proceeding to overtime and verify fields', () {
      _contest.update(
          {'players': _updatedPlayers, 'overtimePlayers': _overtimePlayers});

      expect(_contest.id, matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));
      expect(_contest.isFinished, isFalse);

      expect(_contest.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_contest.duration, matches('0 minutes'));

      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));

      expect(_contest.players, containsAllInOrder(_updatedPlayers));
      expect(_contest.overtimePlayers, containsAllInOrder(_overtimePlayers));
    });

    test('update contest as finished', () {
      _contest.update(
          {'overtimePlayers': _updatedOvertimePlayers, 'isFinished': true});

      expect(_contest.id, matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));
      expect(_contest.isFinished, isTrue);

      expect(_contest.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_contest.duration, matches('0 minutes'));

      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));

      expect(_contest.players, containsAllInOrder(_updatedPlayers));
      expect(_contest.overtimePlayers,
          containsAllInOrder(_updatedOvertimePlayers));
    });

    test('verify map getter after contest\'s finished', () {
      expect(_contest.map['id'], matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));
      expect(_contest.map['isFinished'], isTrue);

      expect(_contest.map['duration'], matches('0 minutes'));

      expect(_contest.map['players'], containsAllInOrder(_updatedPlayers));
      expect(_contest.map['overtimePlayers'],
          containsAllInOrder(_updatedOvertimePlayers));
    });
  });
}
