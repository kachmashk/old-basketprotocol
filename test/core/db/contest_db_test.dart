import 'package:flutter_test/flutter_test.dart';
import 'package:basket_protocol/core/db/user_db.dart';
import 'package:basket_protocol/core/helpers/casters.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

import 'package:basket_protocol/core/db/contest_db.dart';
import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/core/helpers/date_time_parser.dart';

import '../../mocks/mock_players.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final _auth = MockFirebaseAuth();

  group('create contest document ->', () {
    test('should throw an exception if user\'s id is null', () {
      final _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getStarterPlayersA());

      expect(() => ContestDB.createContestDocument(null, _contest),
          throwsException);
    });

    test('should throw an exception if contest is null', () {
      expect(
          () => ContestDB.createContestDocument('xd', null), throwsException);
    });

    test('verify returned contest', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getStarterPlayersA());

      expect(_contest.id, isNull);
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));
      expect(_contest.overtimePlayers, isNull);

      _contest =
          ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      expect(_contest.id, isInstanceOf<String>());
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));
      expect(_contest.overtimePlayers, isNull);

      _dbInstance.dump();
    });

    test('verify created contest document', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      dynamic _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getStarterPlayersA());

      expect(_contest.id, isNull);
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));
      expect(_contest.overtimePlayers, isNull);

      ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      final _fetchedContestsDocuments =
          await ContestDB.fetchContestsDocuments(_user.uid, _dbInstance);

      _contest = Casters.castToContestsList(_fetchedContestsDocuments)[0];

      expect(_contest.id, isInstanceOf<String>());
      expect(_contest.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));
      expect(_contest.overtimePlayers, isNull);

      _dbInstance.dump();
    });
  });
  group('update contest document ->', () {
    test('should throw an exception if user\'s id is null', () {
      final _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getStarterPlayersA());

      expect(() => ContestDB.updateContestDocument(null, _contest),
          throwsException);
    });

    test('should throw an exception if contest is null', () {
      expect(
          () => ContestDB.updateContestDocument('xd', null), throwsException);
    });

    test('proceed to overtime', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      final _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getStarterPlayersA());

      expect(_contest.id, isNull);
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));
      expect(_contest.overtimePlayers, isNull);

      ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      _contest.update({
        'players': MockPlayers.getUpdatedPlayersA(),
        'overtimePlayers': MockPlayers.getStarterPlayersB()
      });

      ContestDB.updateContestDocument(_user.uid, _contest, _dbInstance);

      final _fetchedContestsDocuments =
          await ContestDB.fetchContestsDocuments(_user.uid, _dbInstance);

      final _castedContest =
          Casters.castToContestsList(_fetchedContestsDocuments)[0];

      expect(_castedContest.id, isInstanceOf<String>());
      expect(_castedContest.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_castedContest.isFinished, isFalse);
      expect(_castedContest.duration, matches('0 minutes'));
      expect(_castedContest.throwsPerZone, equals(5));
      expect(_castedContest.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));
      expect(_castedContest.overtimePlayers,
          containsAllInOrder(MockPlayers.getStarterPlayersB()));

      _dbInstance.dump();
    });

    test('finished contest after overtime', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      final _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getUpdatedPlayersA(),
          overtimePlayers: MockPlayers.getStarterPlayersB());

      expect(_contest.id, isNull);
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));
      expect(_contest.overtimePlayers,
          containsAllInOrder(MockPlayers.getStarterPlayersB()));

      ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      _contest.update({
        'isFinished': true,
        'overtimePlayers': MockPlayers.getUpdatedPlayersB()
      });

      ContestDB.updateContestDocument(_user.uid, _contest, _dbInstance);

      final _fetchedContestsDocuments =
          await ContestDB.fetchContestsDocuments(_user.uid, _dbInstance);

      final _castedContest =
          Casters.castToContestsList(_fetchedContestsDocuments)[0];

      expect(_castedContest.id, isInstanceOf<String>());
      expect(_castedContest.title,
          matches('venue - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_castedContest.isFinished, isTrue);
      expect(_castedContest.duration, matches('0 minutes'));
      expect(_castedContest.throwsPerZone, equals(5));
      expect(_castedContest.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));
      expect(_castedContest.overtimePlayers,
          containsAllInOrder(MockPlayers.getUpdatedPlayersB()));

      _dbInstance.dump();
    });
  });
  group('delete contest document ->', () {
    test('should throw an exception if user\'s id is null', () {
      final _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getStarterPlayersA());

      expect(() => ContestDB.deleteContestDocument(null, _contest.id),
          throwsException);
    });

    test('should throw an exception if contest\'s id is null', () {
      expect(
          () => ContestDB.deleteContestDocument('xd', null), throwsException);
    });

    test('delete requested contest document', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      var _contest = Contest(
          venue: 'venue',
          throwsPerZone: 5,
          players: MockPlayers.getUpdatedPlayersA(),
          overtimePlayers: MockPlayers.getStarterPlayersB());

      expect(_contest.id, isNull);
      expect(_contest.isFinished, isFalse);
      expect(_contest.duration, matches('0 minutes'));
      expect(_contest.venue, matches('venue'));
      expect(_contest.throwsPerZone, equals(5));
      expect(_contest.players,
          containsAllInOrder(MockPlayers.getUpdatedPlayersA()));
      expect(_contest.overtimePlayers,
          containsAllInOrder(MockPlayers.getStarterPlayersB()));

      _contest =
          ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      var _fetchedContestDocuments = await ContestDB.fetchContestsDocuments(
          _user.uid, _dbInstance, 'id', _contest.id);

      expect(_fetchedContestDocuments, isNotEmpty);

      ContestDB.deleteContestDocument(_user.uid, _contest.id, _dbInstance);

      _fetchedContestDocuments = await ContestDB.fetchContestsDocuments(
          _user.uid, _dbInstance, 'id', _contest.id);

      expect(_fetchedContestDocuments, isEmpty);

      _dbInstance.dump();
    });
  });

  group('fetch contests documents ->', () {
    test('should throw an exception if user\'s id is null', () {
      expect(
          () => ContestDB.fetchContestsDocuments('xd', null), throwsException);
    });

    test('should return empty contests documents collection', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedContestsDocuments =
          await ContestDB.fetchContestsDocuments(_user.uid, _dbInstance);

      expect(_fetchedContestsDocuments, isEmpty);

      _dbInstance.dump();
    });

    test('fetch & verify populated contests documents collection', () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      var _contest = Contest(
          venue: 'test 1',
          throwsPerZone: 1,
          players: MockPlayers.getStarterPlayersA());

      ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      _contest = Contest(
          venue: 'test 2',
          throwsPerZone: 2,
          players: MockPlayers.getStarterPlayersB());

      ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      final _fetchedContestsDocuments =
          await ContestDB.fetchContestsDocuments(_user.uid, _dbInstance);

      final _fetchedContests =
          Casters.castToContestsList(_fetchedContestsDocuments);

      expect(_fetchedContests[0].id, isInstanceOf<String>());
      expect(_fetchedContests[1].id, isInstanceOf<String>());

      expect(_fetchedContests[0].title,
          matches('test 1 - ${DateTimeParser.getDateTimeNowString()}'));
      expect(_fetchedContests[1].title,
          matches('test 2 - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_fetchedContests[0].throwsPerZone, equals(1));
      expect(_fetchedContests[1].throwsPerZone, equals(2));

      expect(_fetchedContests[0].players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));
      expect(_fetchedContests[1].players,
          containsAllInOrder(MockPlayers.getStarterPlayersB()));

      _dbInstance.dump();
    });

    test('should return empty contests documents collection with given param',
        () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedContestsDocuments = await ContestDB.fetchContestsDocuments(
          _user.uid, _dbInstance, 'id', 'xd');

      expect(_fetchedContestsDocuments, isEmpty);

      _dbInstance.dump();
    });

    test(
        'fetch & verify populated contests documents collection with given param',
        () async {
      final _user = (await _auth.signInWithCredential(null)).user;
      final _dbInstance = MockFirestoreInstance();

      UserDB.createUserDocument(_user, _dbInstance);

      var _contest = Contest(
          venue: 'test 1',
          throwsPerZone: 1,
          players: MockPlayers.getStarterPlayersA());

      final _contestID =
          ContestDB.createContestDocument(_user.uid, _contest, _dbInstance).id;

      _contest = Contest(
          venue: 'test 2',
          throwsPerZone: 2,
          players: MockPlayers.getStarterPlayersB());

      ContestDB.createContestDocument(_user.uid, _contest, _dbInstance);

      final _fetchedContestsDocuments = await ContestDB.fetchContestsDocuments(
          _user.uid, _dbInstance, 'id', _contestID);

      final _fetchedContest =
          Casters.castToContestsList(_fetchedContestsDocuments)[0];

      expect(_fetchedContest.id, isInstanceOf<String>());

      expect(_fetchedContest.title,
          matches('test 1 - ${DateTimeParser.getDateTimeNowString()}'));

      expect(_fetchedContest.throwsPerZone, equals(1));

      expect(_fetchedContest.players,
          containsAllInOrder(MockPlayers.getStarterPlayersA()));

      _dbInstance.dump();
    });
  });
}
