import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

import 'package:basket_protocol/core/db/user_db.dart';
import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/db/match_db.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/core/db/contest_db.dart';
import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/core/helpers/casters.dart';
import 'package:basket_protocol/core/helpers/date_time_parser.dart';

import '../../mocks/mock_players.dart';

void main() {
  final _auth = MockFirebaseAuth();

  group('cast to players ->', () {
    test('should return null when null is passed', () {
      final _result = Casters.castToPlayersList(null);

      expect(_result, isNull);
    });

    test('correctly cast List<dynamic> into List<Map<String, dynamic>>', () {
      final _players = <dynamic>[
        {
          'name': 'player 1',
          'twoPointsMade': 2,
          'twoPointsAttempts': 3,
          'threePointsMade': 1,
          'threePointsAttempts': 3
        },
        {
          'name': 'player 2',
          'twoPointsMade': 4,
          'twoPointsAttempts': 4,
          'threePointsMade': 5,
          'threePointsAttempts': 5
        },
        {
          'name': 'player 3',
          'twoPointsMade': 1,
          'twoPointsAttempts': 3,
          'threePointsMade': 2,
          'threePointsAttempts': 4
        }
      ];

      final _result = Casters.castToPlayersList(_players);
      expect(_result, containsAllInOrder(_players));
    });
  });

  group('cast to team ->', () {
    test('should return null when null is passed', () {
      final _result = Casters.castToTeam(null);

      expect(_result, isNull);
    });

    test('correctly cast Map<String, dynamic> into Team', () {
      final _players = <dynamic>[
        {
          'name': 'player 1',
          'twoPointsMade': 2,
          'twoPointsAttempts': 3,
          'threePointsMade': 1,
          'threePointsAttempts': 3
        },
        {
          'name': 'player 2',
          'twoPointsMade': 4,
          'twoPointsAttempts': 4,
          'threePointsMade': 5,
          'threePointsAttempts': 5
        },
        {
          'name': 'player 3',
          'twoPointsMade': 1,
          'twoPointsAttempts': 3,
          'threePointsMade': 2,
          'threePointsAttempts': 4
        }
      ];

      final _team = <String, dynamic>{'name': 'team name', 'players': _players};
      final _result = Casters.castToTeam(_team);

      expect(_result.name, matches('team name'));
      expect(_result.players, containsAllInOrder(_players));
    });
  });

  group('cast to contests ->', () {
    test('should return null cast when null is passed', () {
      final _result = Casters.castToContestsList(null);

      expect(_result, isNull);
    });

    test(
        'cast empty contests collection -> List<MockDocumentSnapshot> into List<Contest>',
        () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedContests = await ContestDB.fetchContestsDocuments(
        _user.uid,
        _dbInstance,
      );

      final _castedContests = Casters.castToContestsList(_fetchedContests);

      expect(_castedContests, isEmpty);

      _dbInstance.dump();
    });

    test('verify cast List<MockDocumentSnapshot> into List<Contest>', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      for (int i = 1; i < 4; i++) {
        final _contest = Contest(
            venue: 'venue $i',
            throwsPerZone: i,
            players: MockPlayers.getUpdatedPlayersA());

        ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);
      }

      final _fetchedContests =
          await ContestDB.fetchContestsDocuments(_user.uid, _dbInstance);

      final _castedContests = Casters.castToContestsList(_fetchedContests);

      expect(_castedContests.length, equals(3));

      final _contest1 = _castedContests[0];
      final _contest2 = _castedContests[1];
      final _contest3 = _castedContests[2];

      expect(_contest1, isInstanceOf<Contest>());
      expect(_contest2, isInstanceOf<Contest>());
      expect(_contest3, isInstanceOf<Contest>());

      expect(_contest1.title,
          matches('venue 1 - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_contest2.title,
          matches('venue 2 - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_contest3.title,
          matches('venue 3 - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_contest1.throwsPerZone, equals(1));
      expect(_contest2.throwsPerZone, equals(2));
      expect(_contest3.throwsPerZone, equals(3));

      expect(_contest1.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));
      expect(_contest2.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));
      expect(_contest3.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));

      _dbInstance.dump();
    });
  });

  group('cast to matches ->', () {
    test('should return null cast when null is passed', () {
      final _result = Casters.castToMatchesList(null);

      expect(_result, isNull);
    });

    test(
        'cast empty matches collection -> List<MockDocumentSnapshot> into List<Match>',
        () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedMatches = await MatchDB.fetchMatchesDocuments(
        _user.uid,
        _dbInstance,
      );

      final _castedMatches = Casters.castToMatchesList(_fetchedMatches);

      expect(_castedMatches, isEmpty);

      _dbInstance.dump();
    });

    test('verify cast List<MockDocumentSnapshot> into List<Match>', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _match = Match(
        venue: 'venue 1',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      _match = Match(
        venue: 'venue 2',
        gameMode: 'full',
        gameRule: 'points',
        gameRuleValue: 21,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      _match = Match(
        venue: 'venue 3',
        gameMode: 'short',
        gameRule: 'points',
        gameRuleValue: 30,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      final _fetchedMatchs =
          await MatchDB.fetchMatchesDocuments(_user.uid, _dbInstance);

      final _castedMatches = Casters.castToMatchesList(_fetchedMatchs);

      expect(_castedMatches.length, equals(3));

      final _match1 = _castedMatches[0];
      final _match2 = _castedMatches[1];
      final _match3 = _castedMatches[2];

      expect(_match1, isInstanceOf<Match>());
      expect(_match2, isInstanceOf<Match>());
      expect(_match3, isInstanceOf<Match>());

      expect(_match1.title,
          matches('venue 1 - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_match2.title,
          matches('venue 2 - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_match3.title,
          matches('venue 3 - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_match1.gameMode, matches('full'));
      expect(_match2.gameMode, matches('full'));
      expect(_match3.gameMode, matches('short'));

      expect(_match1.gameRule, matches('minutes'));
      expect(_match2.gameRule, matches('points'));
      expect(_match3.gameRule, matches('points'));

      expect(_match1.gameRuleValue, equals(12));
      expect(_match2.gameRuleValue, equals(21));
      expect(_match3.gameRuleValue, equals(30));

      _dbInstance.dump();
    });
  });
}
