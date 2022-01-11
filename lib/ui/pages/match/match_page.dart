import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/core/db/match_db.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/utils/themes/themes.dart';
import 'package:basket_protocol/ui/widgets/custom_button.dart';
import 'package:basket_protocol/ui/widgets/player_banner.dart';
import 'package:basket_protocol/ui/widgets/custom_flushbar.dart';
import 'package:basket_protocol/core/helpers/tables_counters.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/ui/pages/match/match_summary_page.dart';

class MatchPage extends StatefulWidget {
  MatchPage({Key key, @required this.matchData}) : super(key: key);
  final Match matchData;

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> with TickerProviderStateMixin {
  User _user;
  Match _matchData;

  Timer _timer;
  TabController _tabController;

  int _quarterNr;
  int _overtimeNr;

  bool _isLoading = false;
  bool _areButtonsEnabled = false;

  Flushbar _flushbar;
  AnimationController _flushbarController;

  var _teamOnePlayers = <Map<String, dynamic>>[];
  var _teamTwoPlayers = <Map<String, dynamic>>[];

  var _teamsPoints = <String, int>{};
  var _selectedPlayer = <String, dynamic>{};

  var _time, _requestedTime;

  @override
  void initState() {
    super.initState();

    _matchData = widget.matchData;

    _quarterNr = _matchData.quarterNr;
    _overtimeNr = _matchData.overtimeNr;

    _teamOnePlayers = _matchData.teamOne.players;
    _teamTwoPlayers = _matchData.teamTwo.players;

    _selectedPlayer = _matchData.teamOne.players[0];

    _areButtonsEnabled = _matchData.gameRule == 'points' ? true : false;

    _teamsPoints = ({
      'teamOneQuarterPoints': 0,
      'teamTwoQuarterPoints': 0,
      'teamOneTotalPoints': _matchData.teamOne.points,
      'teamTwoTotalPoints': _matchData.teamTwo.points
    });

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    _requestedTime = Duration(minutes: _matchData.gameRuleValue);

    if (_matchData.overtimeNr != 0) {
      double _overtime = _requestedTime.inSeconds / 2;
      _time = Duration(seconds: _overtime.toInt());
      return;
    }

    _time = Duration(minutes: _matchData.gameRuleValue);
  }

  @override
  void dispose() {
    super.dispose();

    if (_timer != null) _timer.cancel();

    _tabController.dispose();
    _flushbarController.dispose();
  }

  void _handleStatisticAction(
      Map<String, dynamic> _player, String _fieldPath, bool _isCancelled) {
    if (_isCancelled) {
      switch (_fieldPath) {
        case 'twoPointsMade':
          _cancelThrowScored(_player, 'twoPointsMade', 'twoPointsAttempts', 2);
          _cancelTeamPointsScored(_player, 2);
          break;

        case 'twoPointsAttempts':
          return _cancelThrowMissed(_player, 'twoPointsAttempts');

        case 'threePointsMade':
          _cancelThrowScored(
              _player, 'threePointsMade', 'threePointsAttempts', 3);
          _cancelTeamPointsScored(_player, 3);
          break;

        case 'threePointsAttempts':
          return _cancelThrowMissed(_player, 'threePointsAttempts');

        case 'assists':
          return setState(() => _player['assists']--);

        case 'rebounds':
          return setState(() => _player['rebounds']--);

        case 'steals':
          return setState(() => _player['steals']--);

        case 'blocks':
          return setState(() => _player['blocks']--);

        case 'turnovers':
          return setState(() => _player['turnovers']--);
      }

      return;
    }

    switch (_fieldPath) {
      case 'twoPointsMade':
        _throwScored(_player, 'twoPointsMade', 'twoPointsAttempts', 2);
        _teamPointsScored(2);
        break;

      case 'twoPointsAttempts':
        return _throwMissed(_player, 'twoPointsAttempts');

      case 'threePointsMade':
        _throwScored(_player, 'threePointsMade', 'threePointsAttempts', 3);
        _teamPointsScored(3);
        break;

      case 'threePointsAttempts':
        return _throwMissed(_player, 'threePointsAttempts');

      case 'assists':
        return setState(() => _player['assists']++);

      case 'rebounds':
        return setState(() => _player['rebounds']++);

      case 'steals':
        return setState(() => _player['steals']++);

      case 'blocks':
        return setState(() => _player['blocks']++);

      case 'turnovers':
        return setState(() => _player['turnovers']++);
    }
  }

  void _handleStatisticButtonClick(String _fieldPath, String _label) {
    const int _duration = 3;
    bool _isActionCancelled = false;
    var _player = _selectedPlayer;

    if (_flushbar != null) _flushbar.dismiss(true);

    _handleStatisticAction(_player, _fieldPath, false);

    setState(() {
      _flushbarController = AnimationController(
        duration: Duration(seconds: _duration),
        vsync: this,
      );

      _flushbarController.forward();

      _flushbar = buildCustomFlushbar(
          _selectedPlayer['name'], _label, _duration, _flushbarController, () {
        _isActionCancelled = true;

        _flushbar.dismiss(true);
        _flushbarController.dispose();

        _handleStatisticAction(_player, _fieldPath, true);
      })
        ..show(context);
    });

    if (_fieldPath != 'twoPointsMade' && _fieldPath != 'threePointsMade') {
      return;
    }

    if (_matchData.gameRule == 'points' &&
        _matchData.gameMode == 'full' &&
        _checkIfQuarterPointsAreReached()) {
      _areButtonsEnabled = false;

      Future.delayed(const Duration(seconds: _duration), () {
        if (!_isActionCancelled) {
          _finishQuarterIfPointsGameModeCheck();
        }

        setState(() => _areButtonsEnabled = true);
        return;
      });
    }

    if (_matchData.gameMode == 'short' && _checkIfMatchPointsAreReached()) {
      _areButtonsEnabled = false;

      Future.delayed(const Duration(seconds: _duration), () {
        if (!_isActionCancelled) {
          _finishShortGameModeCheck();
        }

        setState(() => _areButtonsEnabled = true);
        return;
      });
    }
  }

  void _startTimer() {
    const _oneSec = const Duration(seconds: 1);
    _areButtonsEnabled = true;

    _timer = Timer.periodic(_oneSec, (Timer timer) {
      _time == Duration(seconds: 0)
          ? _endTimer(timer)
          : setState(() => _time -= Duration(seconds: 1));
    });
  }

  void _endTimer(Timer timer) {
    timer.cancel();
    _areButtonsEnabled = false;
    _teamsPoints['teamOneQuarterPoints'] = 0;
    _teamsPoints['teamTwoQuarterPoints'] = 0;

    int _teamOnePoints = _teamsPoints['teamOneTotalPoints'];
    int _teamTwoPoints = _teamsPoints['teamTwoTotalPoints'];

    if (_quarterNr == 4 && _teamOnePoints == _teamTwoPoints) {
      _startOvertime();

      return;
    }

    if (_quarterNr == 4 && _teamOnePoints != _teamTwoPoints) {
      final _updatedMatchData = _updateMatch(true);

      _updateMatchDB(_updatedMatchData);
      _goToMatchSummary(context);

      return;
    }

    buildCustomAlertDialog(context, 'end of the quarter $_quarterNr');

    setState(() {
      _time = _requestedTime;
      _quarterNr++;
    });

    final _updatedMatchData = _updateMatch(false);
    _updateMatchDB(_updatedMatchData);
  }

  void _startOvertime() {
    double _overtime = _requestedTime.inSeconds / 2;
    _time = Duration(seconds: _overtime.toInt());

    if (_overtimeNr > 0) {
      buildCustomAlertDialog(context, 'end of the ot $_overtimeNr');
      setState(() => _overtimeNr++);

      final _updatedMatchData = _updateMatch(false);
      _updateMatchDB(_updatedMatchData);

      return;
    }

    buildCustomAlertDialog(context, 'begin overtime');
    setState(() => _overtimeNr++);

    final _updatedMatchData = _updateMatch(false);
    _updateMatchDB(_updatedMatchData);
  }

  bool _checkIfQuarterPointsAreReached() {
    int _scoreTarget = _matchData.gameRuleValue;

    int _teamOneQuarterPoints = _teamsPoints['teamOneQuarterPoints'];
    int _teamTwoQuarterPoints = _teamsPoints['teamTwoQuarterPoints'];

    return _teamOneQuarterPoints >= _scoreTarget ||
        _teamTwoQuarterPoints >= _scoreTarget;
  }

  void _finishQuarterIfPointsGameModeCheck() {
    int _scoreTarget = _matchData.gameRuleValue;

    int _teamOneTotalPoints = _teamsPoints['teamOneTotalPoints'];
    int _teamTwoTotalPoints = _teamsPoints['teamTwoTotalPoints'];

    setState(() {
      _teamsPoints['teamOneQuarterPoints'] = 0;
      _teamsPoints['teamTwoQuarterPoints'] = 0;
    });

    if (_quarterNr == 4 && _teamOneTotalPoints == _teamTwoTotalPoints) {
      buildCustomAlertDialog(context,
          'end of the regulations. first team to score $_scoreTarget points wins.');

      setState(() => _overtimeNr++);

      final _updatedMatchData = _updateMatch(false);
      _updateMatchDB(_updatedMatchData);

      _areButtonsEnabled = true;
      return;
    }

    if (_quarterNr == 4 && _teamOneTotalPoints != _teamTwoTotalPoints) {
      final _updatedMatchData = _updateMatch(true);

      _updateMatchDB(_updatedMatchData);
      _goToMatchSummary(context);

      return;
    }

    buildCustomAlertDialog(context, 'end of the quarter $_quarterNr');
    setState(() => _quarterNr++);

    final _updatedMatchData = _updateMatch(false);
    _updateMatchDB(_updatedMatchData);

    _areButtonsEnabled = true;
  }

  bool _checkIfMatchPointsAreReached() {
    int _scoreTarget = _matchData.gameRuleValue;

    int _teamOnePoints = _teamsPoints['teamOneQuarterPoints'];
    int _teamTwoPoints = _teamsPoints['teamTwoQuarterPoints'];

    return _teamOnePoints >= _scoreTarget || _teamTwoPoints >= _scoreTarget;
  }

  void _finishShortGameModeCheck() {
    _teamsPoints['teamOneQuarterPoints'] = 0;
    _teamsPoints['teamTwoQuarterPoints'] = 0;

    setState(() => _areButtonsEnabled = false);

    final _updatedMatchData = _updateMatch(true);

    _updateMatchDB(_updatedMatchData);
    _goToMatchSummary(context);
  }

  Match _updateMatch(bool isFinished) {
    _matchData.update({
      'quarterNr': _quarterNr,
      'overtimeNr': _overtimeNr,
      'isFinished': true,
      'teamOne': ({
        'players': _teamOnePlayers,
        'name': _matchData.teamOne.name,
        'points': _teamsPoints['teamOneTotalPoints']
      }),
      'teamTwo': ({
        'players': _teamTwoPlayers,
        'name': _matchData.teamTwo.name,
        'points': _teamsPoints['teamTwoTotalPoints']
      })
    });

    return _matchData;
  }

  Future<void> _updateMatchDB(Match _matchDataToUpdate) async {
    try {
      setState(() => _isLoading = true);

      MatchDB.updateMatchDocument(_user.id, _matchDataToUpdate);

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  void _goToMatchSummary(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchSummaryPage(
          matchData: _matchData,
        ),
      ),
    );
  }

  void _teamPointsScored(int _points) {
    setState(() {
      if (_teamOnePlayers.contains(_selectedPlayer)) {
        _teamsPoints['teamOneQuarterPoints'] += _points;
        _teamsPoints['teamOneTotalPoints'] += _points;

        return;
      }

      _teamsPoints['teamTwoQuarterPoints'] += _points;
      _teamsPoints['teamTwoTotalPoints'] += _points;
    });
  }

  void _cancelTeamPointsScored(Map<String, dynamic> _player, int _points) {
    setState(() {
      if (_teamOnePlayers.contains(_player)) {
        _teamsPoints['teamOneQuarterPoints'] -= _points;
        _teamsPoints['teamOneTotalPoints'] -= _points;

        return;
      }

      _teamsPoints['teamTwoQuarterPoints'] -= _points;
      _teamsPoints['teamTwoTotalPoints'] -= _points;
    });
  }

  void _throwScored(Map<String, dynamic> _player, String _scoredPointsField,
      String _missedPointsField, int _points) {
    setState(() {
      _player['points'] += _points;
      _player[_scoredPointsField]++;
      _player[_missedPointsField]++;
    });
  }

  void _throwMissed(Map<String, dynamic> _player, String _pointsField) {
    setState(() {
      _player[_pointsField]++;
    });
  }

  void _cancelThrowScored(Map<String, dynamic> _player,
      String _scoredPointsField, String _missedPointsField, int _points) {
    setState(() {
      _player['points'] -= _points;
      _player[_scoredPointsField]--;
      _player[_missedPointsField]--;
    });
  }

  void _cancelThrowMissed(Map<String, dynamic> _player, String _pointsField) {
    setState(() {
      _player[_pointsField]--;
    });
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      setState(() => _selectedPlayer = _teamOnePlayers[0]);

      return;
    }

    setState(() => _selectedPlayer = _teamTwoPlayers[0]);
  }

  String _buildTabBarTitle(int _teamNr) {
    int _totalPoints;
    int _quarterPoints;
    String _teamName;

    switch (_teamNr) {
      case 1:
        {
          _teamName = _matchData.teamOne.name;
          _totalPoints = _teamsPoints['teamOneTotalPoints'];
          _quarterPoints = _teamsPoints['teamOneQuarterPoints'];
        }
        break;

      case 2:
        {
          _teamName = _matchData.teamTwo.name;
          _totalPoints = _teamsPoints['teamTwoTotalPoints'];
          _quarterPoints = _teamsPoints['teamTwoQuarterPoints'];
        }
        break;
    }

    if (_matchData.gameRule == 'minutes' || _matchData.gameMode == 'short') {
      return '$_totalPoints: $_teamName';
    }

    if (_matchData.gameRule == 'points' && _matchData.gameMode == 'full') {
      return '$_quarterPoints: $_teamName';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);

    return WillPopScope(
      onWillPop: () => buildCustomAlertDialog(
        context,
        'match saves after each quarter. you\'ll be able to finish this match later',
        CustomButton(
          key: Key('quitButton'),
          label: 'quit',
          isFlatButtonWanted: true,
          onClick: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MatchSetupPage(),
            ),
            (route) => false,
          ),
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: LoadingOverlay(
          color: Colors.transparent.withOpacity(.8),
          isLoading: _isLoading,
          child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      leading: IconButton(
        icon: Icon(Icons.home),
        onPressed: () => buildCustomAlertDialog(
          context,
          'match saves after each quarter. you\'ll be able to finish this match later',
          CustomButton(
            key: Key('quitButton'),
            label: 'quit',
            isFlatButtonWanted: true,
            onClick: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MatchSetupPage(),
              ),
              (route) => false,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
            padding: const EdgeInsets.all(2),
            child: _matchData.gameRule != 'points'
                ? Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          if (_timer == null || !_timer.isActive) _startTimer();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () {
                          setState(
                            (() {
                              _timer.cancel();
                              _areButtonsEnabled = false;
                            }),
                          );
                        },
                      )
                    ],
                  )
                : null)
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            text: _buildTabBarTitle(1),
          ),
          Tab(
            text: _buildTabBarTitle(2),
          ),
          Tab(text: 'summary')
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        _buildTeamView(1),
        _buildTeamView(2),
        _buildSummaryView()
      ],
    );
  }

  Widget _buildAppBarTitle() {
    Text _title;

    switch (_matchData.gameMode) {
      case 'full':
        {
          if (_matchData.gameRule == 'minutes' && _overtimeNr > 0) {
            _title = Text(
                'ot$_overtimeNr: ${_time.toString().split(':')[1] + ":" + _time.toString().split(':')[2].split('.')[0]}');
          } else if (_matchData.gameRule == 'minutes' && _overtimeNr == 0) {
            _title = Text(
                'quarter $_quarterNr: ${_time.toString().split(':')[1] + ":" + _time.toString().split(':')[2].split('.')[0]}');
          }

          if (_matchData.gameRule == 'points' && _overtimeNr > 0) {
            _title = Text('target: ${_matchData.gameRuleValue} points');
          } else if (_matchData.gameRule == 'points' && _overtimeNr == 0) {
            _title = Text(
                'quarter: $_quarterNr, target: ${_matchData.gameRuleValue} points');
          }
        }
        break;

      case 'short':
        {
          _title = Text('target points: ${_matchData.gameRuleValue}');
        }
        break;
    }

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _title,
      ),
    );
  }

  Widget _buildTeamView(int _teamNr) {
    List _players;
    Color _color;
    Color _selectedPlayerColor = Themes.getSelectedPlayerColor();

    switch (_teamNr) {
      case 1:
        {
          _players = _teamOnePlayers;
          _color = Themes.getTeamOneColor();
        }
        break;

      case 2:
        {
          _players = _teamTwoPlayers;
          _color = Themes.getTeamTwoColor();
        }
        break;
    }

    return ListView(
      children: <Widget>[
        Column(
          children: _players
              .map<Widget>(
                (player) => FadeInAnimation(
                  delay: 100,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  opacityMilliseconds: 200,
                  child: PlayerBanner(
                    player: player,
                    color: player['name'] == _selectedPlayer['name']
                        ? _selectedPlayerColor
                        : _color,
                    onClick: () => setState(() => _selectedPlayer = player),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_tabController.index == 2) return null;

    return Stack(
      children: <Widget>[
        Container(height: 320),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: FadeInAnimation(
            delay: 200,
            transitionXBegin: 0.0,
            curve: Curves.ease,
            child: Container(
              margin: const EdgeInsets.all(2),
              child: Column(
                children: <Widget>[
                  FadeInAnimation(
                    delay: 300,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomButton(
                            key: Key('switchTeamButton'),
                            onClick: () {
                              setState(() {
                                if (_tabController.index == 0) {
                                  _tabController.index = 1;
                                  return;
                                }

                                _tabController.index = 0;
                              });
                            },
                            label: 'switch team',
                            color: Colors.deepOrangeAccent,
                            margin: const EdgeInsets.all(2),
                            padding: const EdgeInsets.all(1),
                          ),
                        )
                      ],
                    ),
                  ),
                  FadeInAnimation(
                    delay: 400,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: Row(
                      children: <Widget>[
                        _buildStatisticButton(
                          '+2pts',
                          'twoPointsMade',
                          Color.fromRGBO(
                            0,
                            200,
                            0,
                            .6,
                          ),
                        ),
                        _buildStatisticButton(
                          '+2pts attempt',
                          'twoPointsAttempts',
                          Color.fromRGBO(
                            255,
                            0,
                            0,
                            .6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeInAnimation(
                    delay: 600,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: Row(
                      children: <Widget>[
                        _buildStatisticButton(
                          '+3pts',
                          'threePointsMade',
                          Color.fromRGBO(
                            0,
                            200,
                            0,
                            .6,
                          ),
                        ),
                        _buildStatisticButton(
                          '+3pts attempt',
                          'threePointsAttempts',
                          Color.fromRGBO(
                            255,
                            0,
                            0,
                            .6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeInAnimation(
                    delay: 800,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: Row(
                      children: <Widget>[
                        _buildStatisticButton('+assist', 'assists'),
                      ],
                    ),
                  ),
                  FadeInAnimation(
                    delay: 1000,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: Row(
                      children: <Widget>[
                        _buildStatisticButton('+rebound', 'rebounds'),
                        _buildStatisticButton('+block', 'blocks'),
                      ],
                    ),
                  ),
                  FadeInAnimation(
                    delay: 1200,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: Row(
                      children: <Widget>[
                        _buildStatisticButton('+steal', 'steals'),
                        _buildStatisticButton('+turnover', 'turnovers'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatisticButton(String _label, String _fieldPath,
      [final _color]) {
    return Expanded(
      child: CustomButton(
        key: Key('statisticButton'),
        label: '$_label: ${_selectedPlayer[_fieldPath]}',
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(.6),
        color: _color,
        onClick: _areButtonsEnabled
            ? () => _handleStatisticButtonClick(_fieldPath, _label)
            : null,
      ),
    );
  }

  Widget _buildSummaryView() {
    var _allPlayers = _teamOnePlayers + _teamTwoPlayers;

    return ListView(
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 28,
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      headingRowHeight: 26,
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text(''),
                        ),
                        DataColumn(
                          label: Text(
                            'pts',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '2pts',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '2p%',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '3pts',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '3p%',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'fg',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'fg%',
                          ),
                        ),
                      ],
                      rows: _allPlayers
                          .map<DataRow>(
                            (player) => DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  Text(
                                    '${player['name']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${player['points']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    TablesCounters.twoPointersTotal(
                                      player,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    TablesCounters.twoPointersPercentageTotal(
                                      player,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    TablesCounters.threePointersTotal(
                                      player,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    TablesCounters.threePointersPercentageTotal(
                                      player,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    TablesCounters.fieldGoalsTotal(
                                      player,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    TablesCounters.fieldGoalsPercentageTotal(
                                      player,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.transparent,
                height: 32,
                indent: 22,
                endIndent: 22,
              ),
              Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 28,
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      headingRowHeight: 26,
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text(''),
                        ),
                        DataColumn(
                          label: Text(
                            'assists',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'rebounds',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'blocks',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'steals',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'turnovers',
                          ),
                        ),
                      ],
                      rows: _allPlayers
                          .map<DataRow>(
                            (player) => DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  Text(
                                    '${player['name']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${player['assists']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${player['rebounds']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${player['blocks']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${player['steals']}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${player['turnovers']}',
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ])
      ],
    );
  }
}
