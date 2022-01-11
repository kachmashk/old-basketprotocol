import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

import 'package:basket_protocol/core/models/contest.dart';

class ContestDB {
  static Contest createContestDocument(String _userId, Contest _contestData,
      [MockFirestoreInstance _mockDBInstance]) {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      if (_contestData == null) {
        throw Exception('contest cannot be null');
      }

      Contest _contest = _contestData;
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      final _createdBlankDocument = _dbInstance
          .collection('users')
          .document(_userId)
          .collection('contests')
          .document();

      _dbInstance
          .collection('users')
          .document(_userId)
          .collection('contests')
          .document(_createdBlankDocument.documentID)
          .setData({
        'id': _createdBlankDocument.documentID,
        'date': new DateTime.now(),
        'title': _contest.title,
        'throwsPerZone': _contest.throwsPerZone,
        'isFinished': _contest.isFinished,
        'duration': _contest.duration,
        'players': _contest.players,
      });

      _contest.id = _createdBlankDocument.documentID;

      return _contest;
    } catch (error) {
      throw Exception(error);
    }
  }

  static void updateContestDocument(String _userId, Contest _contest,
      [MockFirestoreInstance _mockDBInstance]) {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      if (_contest == null) {
        throw Exception('contest cannot be null');
      }

      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      _dbInstance
          .collection('users')
          .document(_userId)
          .collection('contests')
          .document(_contest.id)
          .updateData(_contest.map);
    } catch (error) {
      throw Exception(error);
    }
  }

  static void deleteContestDocument(String _userId, String _contestId,
      [MockFirestoreInstance _mockDBInstance]) {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      if (_contestId == null) {
        throw Exception('contest id cannot be null');
      }

      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      _dbInstance
          .collection('users')
          .document(_userId)
          .collection('contests')
          .document(_contestId)
          .delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<DocumentSnapshot>> fetchContestsDocuments(String _userId,
      [MockFirestoreInstance _mockDBInstance,
      String _param,
      final _value]) async {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      if (_param != null) {
        final _result = await _dbInstance
            .collection('users')
            .document(_userId)
            .collection('contests')
            .where('$_param', isEqualTo: _value)
            .orderBy('date', descending: true)
            .getDocuments();

        return _result.documents;
      }

      final _result = await _dbInstance
          .collection('users')
          .document(_userId)
          .collection('contests')
          .orderBy('date', descending: true)
          .getDocuments();

      return _result.documents;
    } catch (error) {
      throw Exception(error);
    }
  }
}
