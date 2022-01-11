import 'package:flutter_test/flutter_test.dart';

import 'package:basket_protocol/core/models/team.dart';

import '../../mocks/mock_players.dart';

void main() {
  final _players = MockPlayers.getStarterPlayersA();
  final _updatedPlayers = MockPlayers.getUpdatedPlayersA();

  final _team = Team(name: 'name', players: _players);

  group('team model ->', () {
    test('verify created team\'s fields', () {
      expect(_team.name, matches('name'));
      expect(_team.points, equals(0));
      expect(_team.players, containsAllInOrder(_players));
    });

    test('team update and verify fields', () {
      int _x = 0;

      for (final _players in MockPlayers.getUpdatedPlayersA()) {
        _x += _players['twoPointsMade'] * 2;
        _x += _players['threePointsMade'] * 3;
      }

      expect(_x, greaterThan(0));

      _team.update(_updatedPlayers);

      expect(_team.name, matches('name'));
      expect(_team.points, greaterThan(0));
      expect(_team.players, containsAllInOrder(_updatedPlayers));
    });
  });
}
