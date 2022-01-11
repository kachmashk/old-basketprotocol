import 'package:flutter_test/flutter_test.dart';

import 'package:basket_protocol/core/db/user_db.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final _auth = MockFirebaseAuth();

  group('create user document ->', () {
    test('should correctly populates db', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedDocuments =
          await UserDB.fetchUsersDocuments(_dbInstance, 'id', _user.uid);

      expect(_fetchedDocuments, isNotEmpty);

      _dbInstance.dump();
    });
  });

  group('update user document ->', () {
    test('should correctly update document with email', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _fetchedDocuments =
          await UserDB.fetchUsersDocuments(_dbInstance, 'id', _user.uid);

      expect(_fetchedDocuments[0].data['email'], isNull);

      UserDB.updateUserEmail(_user, 'test@mail.mock', _dbInstance);

      _fetchedDocuments =
          await UserDB.fetchUsersDocuments(_dbInstance, 'id', _user.uid);

      expect(_fetchedDocuments[0].data['email'], 'test@mail.mock');

      _dbInstance.dump();
    });
  });

  group('delete user document ->', () {
    test('should correctly delete document', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      var _fetchedDocuments =
          await UserDB.fetchUsersDocuments(_dbInstance, 'id', _user.uid);

      expect(_fetchedDocuments, isNotEmpty);

      await UserDB.deleteUserDocument(_user.uid, _dbInstance);

      _fetchedDocuments =
          await UserDB.fetchUsersDocuments(_dbInstance, 'id', _user.uid);

      expect(_fetchedDocuments, isEmpty);

      _dbInstance.dump();
    });
  });

  group('does user document exists ->', () {
    test('should return false for user that does not exist', () async {
      final _dbInstance = MockFirestoreInstance();

      final _doesUserExist =
          await UserDB.doesUserExists('rAndOmID', _dbInstance);

      expect(_doesUserExist, isFalse);

      _dbInstance.dump();
    });

    test('should return true for user that does exists', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      final _doesUserExist =
          await UserDB.doesUserExists(_user.uid, _dbInstance);

      expect(_doesUserExist, isTrue);

      _dbInstance.dump();
    });
  });

  group('fetch user documents ->', () {
    test('fetch empty collection', () async {
      final _dbInstance = MockFirestoreInstance();
      final _fetchedDocuments = await UserDB.fetchUsersDocuments(_dbInstance);

      expect(_fetchedDocuments, isEmpty);

      _dbInstance.dump();
    });

    test('fetch populated collection', () async {
      final _dbInstance = MockFirestoreInstance();
      final _user = (await _auth.signInWithCredential(null)).user;

      UserDB.createUserDocument(_user, _dbInstance);

      final _fetchedDocuments = await UserDB.fetchUsersDocuments(_dbInstance);

      expect(_fetchedDocuments, isNotEmpty);
      expect(_fetchedDocuments[0].data['id'], matches(_user.uid));

      _dbInstance.dump();
    });
  });
}
