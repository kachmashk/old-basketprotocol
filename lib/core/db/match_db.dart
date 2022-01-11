import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

import 'package:basket_protocol/core/models/match.dart';

class MatchDB {
  static Match createMatchDocument(String _userId, Match _matchData,
      [MockFirestoreInstance _mockDBInstance]) {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      if (_matchData == null) {
        throw Exception('match cannot be null');
      }

      Match _match = _matchData;
      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      final _createdBlankDocument = _dbInstance
          .collection('users')
          .document(_userId)
          .collection('matches')
          .document();

      _dbInstance
          .collection('users')
          .document(_userId)
          .collection('matches')
          .document(_createdBlankDocument.documentID)
          .setData({
        'id': _createdBlankDocument.documentID,
        'date': new DateTime.now(),
        'title': _match.title,
        'gameRule': _match.gameRule,
        'gameMode': _match.gameMode,
        'gameRuleValue': _match.gameRuleValue,
        'isFinished': _match.isFinished,
        'duration': _match.duration,
        'teamOne': ({
          'name': _match.teamOne.name,
          'points': _match.teamOne.points,
          'players': _match.teamOne.players
        }),
        'teamTwo': ({
          'name': _match.teamTwo.name,
          'points': _match.teamTwo.points,
          'players': _match.teamTwo.players
        }),
      });

      _match.id = _createdBlankDocument.documentID;

      return _match;
    } catch (error) {
      throw Exception(error);
    }
  }

  static void updateMatchDocument(String _userId, Match _matchData,
      [MockFirestoreInstance _mockDBInstance]) {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      if (_matchData == null) {
        throw Exception('match cannot be null');
      }

      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      _dbInstance
          .collection('users')
          .document(_userId)
          .collection('matches')
          .document(_matchData.id)
          .updateData(_matchData.map);
    } catch (error) {
      throw Exception(error);
    }
  }

  static void deleteMatchDocument(String _userId, String _matchId,
      [MockFirestoreInstance _mockDBInstance]) {
    try {
      if (_userId == null) {
        throw Exception('user id cannot be null');
      }

      if (_matchId == null) {
        throw Exception('match id cannot be null');
      }

      final _dbInstance = _mockDBInstance ?? Firestore.instance;

      _dbInstance
          .collection('users')
          .document(_userId)
          .collection('matches')
          .document(_matchId)
          .delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<DocumentSnapshot>> fetchMatchesDocuments(String _userId,
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
            .collection('matches')
            .where('$_param', isEqualTo: _value)
            .orderBy('date', descending: true)
            .getDocuments();

        return _result.documents;
      }

      final _result = await _dbInstance
          .collection('users')
          .document(_userId)
          .collection('matches')
          .orderBy('date', descending: true)
          .getDocuments();

      return _result.documents;
    } catch (error) {
      throw Exception(error);
    }
  }
}
