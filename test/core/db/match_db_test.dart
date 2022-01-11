import 'package:basket_protocol/core/helpers/casters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

import 'package:basket_protocol/core/db/user_db.dart';
import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/db/match_db.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/core/helpers/date_time_parser.dart';

import '../../mocks/mock_players.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final _auth = MockFirebaseAuth();
  group('create match document ->', () {
    test('should throw an exception if user\'s id is null', () {
      final _match = Match(
        venue: 'venue',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      expect(() => MatchDB.createMatchDocument(null, _match), throwsException);
    });

    test('should throw an exception if match is null', () {
      expect(() => MatchDB.createMatchDocument('xd', null), throwsException);
    });

    test('verify returned match', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _match = Match(
        venue: 'venue',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      _match = MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      expect(_match.id, isInstanceOf<String>());
      expect(_match.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_match.quarterNr, equals(1));
      expect(_match.overtimeNr, equals(0));

      expect(_match.gameRule, matches('minutes'));
      expect(_match.gameMode, matches('full'));
      expect(_match.gameRuleValue, equals(12));

      expect(_match.teamOne.name, matches('team one name'));
      expect(_match.teamOne.points, equals(0));
      expect(_match.teamOne.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));

      expect(_match.teamTwo.name, matches('team two name'));
      expect(_match.teamTwo.points, equals(0));
      expect(_match.teamTwo.players,
          containsAllInOrder(MockPlayers.getStarterPlayersB()));

      _dbInstance.dump();
    });

    test('verify created match document', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _match = Match(
        venue: 'venue',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      _match = MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      final _fetchedData = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', _match.id);

      expect(_fetchedData, isNotEmpty);

      _dbInstance.dump();
    });
  });

  group('update match document ->', () {
    test('should throw an exception if user\'s id is null', () {
      final _match = Match(
        venue: 'venue',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      expect(() => MatchDB.updateMatchDocument(null, _match), throwsException);
    });

    test('should throw an exception if match is null', () {
      expect(() => MatchDB.updateMatchDocument('xd', null), throwsException);
    });

    var _match = Match(
      venue: 'venue',
      gameMode: 'full',
      gameRule: 'minutes',
      gameRuleValue: 12,
      teamOne: Team(
          name: 'team one name', players: MockPlayers.getStarterPlayersA()),
      teamTwo: Team(
          name: 'team two name', players: MockPlayers.getStarterPlayersB()),
    );

    test('proceed to fourth quarter', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      _match = MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      _match.update({
        'quarterNr': 4,
        'teamOne': {'players': MockPlayers.getUpdatedPlayersA()},
        'teamTwo': {'players': MockPlayers.getUpdatedPlayersB()}
      });

      MatchDB.updateMatchDocument(_user.uid, _match, _dbInstance);

      final _fetchedMatchDocument = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', _match.id);

      final _castedMatch = Casters.castToMatchesList(_fetchedMatchDocument)[0];

      expect(_castedMatch.quarterNr, equals(4));
      expect(_castedMatch.overtimeNr, equals(0));

      expect(_castedMatch.teamOne.points, greaterThan(0));
      expect(_castedMatch.teamOne.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));

      expect(_castedMatch.teamTwo.points, greaterThan(0));
      expect(_castedMatch.teamTwo.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersB()));
      _dbInstance.dump();
    });

    test('finish match after two overtimes', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      _match.update({'overtimeNr': 2, 'isFinished': true});

      MatchDB.updateMatchDocument(_user.uid, _match, _dbInstance);

      final _fetchedMatchDocument = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', _match.id);

      final _castedMatch = Casters.castToMatchesList(_fetchedMatchDocument)[0];

      expect(_castedMatch.isFinished, isTrue);

      expect(_castedMatch.quarterNr, equals(4));
      expect(_castedMatch.overtimeNr, equals(2));

      expect(_castedMatch.teamOne.points, greaterThan(0));
      expect(_castedMatch.teamOne.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));

      expect(_castedMatch.teamTwo.points, greaterThan(0));
      expect(_castedMatch.teamTwo.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersB()));
      _dbInstance.dump();
    });
  });

  group('delete match document ->', () {
    test('should throw an exception if user\'s id is null', () {
      final _match = Match(
        venue: 'venue',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      expect(
          () => MatchDB.deleteMatchDocument(null, _match.id), throwsException);
    });

    test('should throw an exception if match\'s id is null', () {
      expect(() => MatchDB.deleteMatchDocument('xd', null), throwsException);
    });

    test('should correctly delete document', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _match = Match(
        venue: 'venue',
        gameMode: 'full',
        gameRule: 'minutes',
        gameRuleValue: 12,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      _match = MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      var _fetchedMatchesDocuments = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', _match.id);

      expect(_fetchedMatchesDocuments, isNotEmpty);

      MatchDB.deleteMatchDocument(_user.uid, _match.id, _dbInstance);

      _fetchedMatchesDocuments = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', _match.id);

      expect(_fetchedMatchesDocuments, isEmpty);

      _dbInstance.dump();
    });
  });

  group('fetch match document ->', () {
    test('should throw an exception if user\'s id is null', () {
      expect(() => MatchDB.fetchMatchesDocuments('xd', null), throwsException);
    });

    test('should return empty matches documents collection', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedMatchesDocuments =
          await MatchDB.fetchMatchesDocuments(_user.uid, _dbInstance);

      expect(_fetchedMatchesDocuments, isEmpty);

      _dbInstance.dump();
    });

    test('fetch & verify populated matches documents collection', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      var _match = Match(
        venue: 'test 1',
        gameMode: 'full',
        gameRule: 'points',
        gameRuleValue: 30,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      _match = Match(
        venue: 'test 2',
        gameMode: 'short',
        gameRule: 'points',
        gameRuleValue: 21,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      final _fetchedMatchesDocuments =
          await MatchDB.fetchMatchesDocuments(_user.uid, _dbInstance);

      final _fetchedMatches =
          Casters.castToMatchesList(_fetchedMatchesDocuments);

      expect(_fetchedMatches[0].id, isInstanceOf<String>());
      expect(_fetchedMatches[1].id, isInstanceOf<String>());

      expect(_fetchedMatches[0].title,
          matches('test 1 - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_fetchedMatches[1].title,
          matches('test 2 - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_fetchedMatches[0].gameMode, matches('full'));
      expect(_fetchedMatches[1].gameMode, matches('short'));

      expect(_fetchedMatches[0].gameRule, matches('points'));
      expect(_fetchedMatches[1].gameRule, matches('points'));

      expect(_fetchedMatches[0].gameRuleValue, equals(30));
      expect(_fetchedMatches[1].gameRuleValue, equals(21));

      expect(_fetchedMatches[0].quarterNr, equals(1));
      expect(_fetchedMatches[1].quarterNr, equals(1));

      expect(_fetchedMatches[0].overtimeNr, equals(0));
      expect(_fetchedMatches[1].overtimeNr, equals(0));

      _dbInstance.dump();
    });

    test('should return empty matches documents collection with given param',
        () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedMatchesDocuments = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', 'xd');

      expect(_fetchedMatchesDocuments, isEmpty);

      _dbInstance.dump();
    });

    test(
        'fetch & verify populated matches documents collection with given param',
        () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      var _match = Match(
        venue: 'test 1',
        gameMode: 'full',
        gameRule: 'points',
        gameRuleValue: 30,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      final _matchID =
          MatchDB.createMatchDocument(_user.uid, _match, _dbInstance).id;

      _match = Match(
        venue: 'test 2',
        gameMode: 'short',
        gameRule: 'points',
        gameRuleValue: 21,
        teamOne: Team(
            name: 'team one name', players: MockPlayers.getStarterPlayersA()),
        teamTwo: Team(
            name: 'team two name', players: MockPlayers.getStarterPlayersB()),
      );

      MatchDB.createMatchDocument(_user.uid, _match, _dbInstance);

      final _fetchedMatchesDocuments = await MatchDB.fetchMatchesDocuments(
          _user.uid, _dbInstance, 'id', _matchID);

      final _fetchedMatch =
          Casters.castToMatchesList(_fetchedMatchesDocuments)[0];

      expect(_fetchedMatch.id, isInstanceOf<String>());

      expect(_fetchedMatch.title,
          matches('test 1 - ${DateTimeParser.getDateTimeNowString()}'));

      _dbInstance.dump();
    });
  });
}
