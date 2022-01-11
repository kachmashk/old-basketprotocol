import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/core/models/contest.dart';

class Casters {
  static List<Map<String, dynamic>> castToPlayersList(List<dynamic> _players) {
    if (_players == null) return null;

    return _players
        .map<Map<String, dynamic>>((player) => player as Map<String, dynamic>)
        .toList();
  }

  static Team castToTeam(Map<String, dynamic> _team) {
    if (_team == null) return null;

    return Team(
        name: _team['name'], players: castToPlayersList(_team['players']));
  }

  static List<Contest> castToContestsList(List<dynamic> _contests) {
    if (_contests == null) return null;

    return _contests
        .map<Contest>((contest) => Contest(
              id: contest.data['id'],
              title: contest.data['title'],
              isFinished: contest.data['isFinished'],
              throwsPerZone: contest.data['throwsPerZone'],
              players: castToPlayersList(contest.data['players']),
              overtimePlayers:
                  castToPlayersList(contest.data['overtimePlayers']),
            ))
        .toList();
  }

  static List<Match> castToMatchesList(List<dynamic> _matches) {
    if (_matches == null) return null;

    return _matches
        .map<Match>((match) => Match(
            id: match.data['id'],
            title: match.data['title'],
            quarterNr: match.data['quarterNr'],
            overtimeNr: match.data['overtimeNr'],
            isFinished: match.data['isFinished'],
            gameMode: match.data['gameMode'],
            gameRule: match.data['gameRule'],
            gameRuleValue: match.data['gameRuleValue'],
            teamOne: castToTeam(match.data['teamOne']),
            teamTwo: castToTeam(match.data['teamTwo'])))
        .toList();
  }
}
