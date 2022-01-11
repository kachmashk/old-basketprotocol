import 'package:flutter_test/flutter_test.dart';

import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/core/helpers/date_time_parser.dart';

import '../../mocks/mock_players.dart';

void main() {
  final _teamOne =
      Team(name: 'team one name', players: MockPlayers.getStarterPlayersA());
  final _teamTwo =
      Team(name: 'team two name', players: MockPlayers.getStarterPlayersB());

  final _match = Match(
      venue: 'venue',
      gameMode: 'full',
      gameRule: 'minutes',
      gameRuleValue: 10,
      teamOne: _teamOne,
      teamTwo: _teamTwo);

  group('match model ->', () {
    test('verify created match\'s fields', () {
      expect(_match.id, isNull);

      expect(_match.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_match.venue, matches('venue'));
      expect(_match.duration, matches('0 minutes'));

      expect(_match.gameMode, matches('full'));
      expect(_match.gameRule, matches('minutes'));
      expect(_match.gameRuleValue, equals(10));

      expect(_match.quarterNr, equals(1));
      expect(_match.overtimeNr, equals(0));

      expect(_match.isFinished, isFalse);

      expect(_match.teamOne.name, matches('team one name'));
      expect(_match.teamOne.points, equals(0));
      expect(_match.teamOne.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));

      expect(_match.teamTwo.name, matches('team two name'));
      expect(_match.teamTwo.points, equals(0));
      expect(_match.teamTwo.players,
          containsAllInOrder(MockPlayers.getStarterPlayersB()));
    });

    test('verify map getter', () {
      expect(_match.map['id'], isNull);

      expect(_match.map['quarterNr'], equals(1));
      expect(_match.map['overtimeNr'], equals(0));

      expect(_match.map['isFinished'], isFalse);

      expect(_match.map['duration'], matches('0 minutes'));

      expect(_match.map['teamOne']['name'], matches('team one name'));
      expect(_match.map['teamOne']['points'], equals(0));
      expect(_match.map['teamOne']['players'],
          containsAllInOrder(MockPlayers.getStarterPlayersA()));

      expect(_match.map['teamTwo']['name'], matches('team two name'));
      expect(_match.map['teamTwo']['points'], equals(0));
      expect(_match.map['teamTwo']['players'],
          containsAllInOrder(MockPlayers.getStarterPlayersB()));
    });

    test('set match\'es id', () {
      _match.id = 'FeArey7LgeX9IOAkWsxAQc1gEs33';

      expect(_match.id, matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));
    });

    test('update being match & verify updated fields', () {
      _match.update({
        'quarterNr': 3,
        'teamOne': {'players': MockPlayers.getUpdatedPlayersA()},
        'teamTwo': {'players': MockPlayers.getUpdatedPlayersB()}
      });

      expect(_match.id, matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));

      expect(_match.quarterNr, equals(3));
      expect(_match.overtimeNr, equals(0));

      expect(_match.isFinished, isFalse);

      expect(_match.teamOne.name, matches('team one name'));
      expect(_match.teamOne.points, greaterThan(0));
      expect(_match.teamOne.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));

      expect(_match.teamTwo.name, matches('team two name'));
      expect(_match.teamTwo.points, greaterThan(0));
      expect(_match.teamTwo.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersB()));
    });

    test('update finished match & verify updated fields', () {
      _match.update({
        'quarterNr': 4,
        'isFinished': true,
      });

      expect(_match.id, matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));

      expect(_match.quarterNr, equals(4));
      expect(_match.overtimeNr, equals(0));

      expect(_match.isFinished, isTrue);

      expect(_match.teamOne.name, matches('team one name'));
      expect(_match.teamOne.points, greaterThan(0));
      expect(_match.teamOne.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));

      expect(_match.teamTwo.name, matches('team two name'));
      expect(_match.teamTwo.points, greaterThan(0));
      expect(_match.teamTwo.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersB()));
    });

    test('verify map getter after match\'s finished', () {
      expect(_match.map['id'], matches('FeArey7LgeX9IOAkWsxAQc1gEs33'));
      expect(_match.map['duration'], matches('0 minutes'));

      expect(_match.map['quarterNr'], equals(4));
      expect(_match.map['overtimeNr'], equals(0));

      expect(_match.map['isFinished'], isTrue);

      expect(_match.map['teamOne']['name'], matches('team one name'));
      expect(_match.map['teamOne']['points'], greaterThan(0));
      expect(_match.map['teamOne']['players'],
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));

      expect(_match.map['teamTwo']['name'], matches('team two name'));
      expect(_match.map['teamTwo']['points'], greaterThan(0));
      expect(_match.map['teamTwo']['players'],
          containsAllInOrder(MockPlayers.getUpdatedPlayersB()));
    });
  });
}
