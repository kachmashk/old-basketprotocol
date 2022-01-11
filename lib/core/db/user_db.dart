import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

class UserDB {
  static Future<void> createUserDocument(FirebaseUser _user,
      [MockFirestoreInstance _mockDBInstance]) async {
    try {
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      await _dbInstance
          .collection('users')
          .document(_user.uid)
          .setData({'email': _user.email, 'id': _user.uid});
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<void> updateUserEmail(FirebaseUser _user, String _email,
      [MockFirestoreInstance _mockDBInstance]) async {
    try {
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      await _dbInstance
          .collection('users')
          .document(_user.uid)
          .updateData({'email': _email});
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<void> deleteUserDocument(String _id,
      [MockFirestoreInstance _mockDBInstance]) async {
    try {
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      final _fetchedMatches = await _dbInstance
          .collection('users')
          .document(_id)
          .collection('matches')
          .getDocuments();
      for (DocumentSnapshot _matches in _fetchedMatches.documents) {
        _matches.reference.delete();
      }

      final _fetchedContests = await _dbInstance
          .collection('users')
          .document(_id)
          .collection('contests')
          .getDocuments();
      for (DocumentSnapshot _contests in _fetchedContests.documents) {
        _contests.reference.delete();
      }

      await _dbInstance.collection('users').document(_id).delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<bool> doesUserExists(String _id,
      [MockFirestoreInstance _mockDBInstance]) async {
    try {
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      final _registeredUsers = await _dbInstance
          .collection('users')
          .where('id', isEqualTo: _id)
          .getDocuments();

      return _registeredUsers.documents.isNotEmpty;
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<DocumentSnapshot>> fetchUsersDocuments(
      [MockFirestoreInstance _mockDBInstance,
      String _param,
      final _value]) async {
    try {
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      if (_param != null) {
        final _response = await _dbInstance
            .collection('users')
            .where('$_param', isEqualTo: _value)
            .getDocuments();

        return _response.documents;
      }

      final _response = await _dbInstance.collection('users').getDocuments();

      return _response.documents;
    } catch (error) {
      throw Exception(error);
    }
  }
}
