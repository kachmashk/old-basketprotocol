import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/core/db/contest_db.dart';
import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/utils/themes/themes.dart';
import 'package:basket_protocol/ui/widgets/custom_button.dart';
import 'package:basket_protocol/ui/widgets/player_banner.dart';
import 'package:basket_protocol/ui/widgets/custom_flushbar.dart';
import 'package:basket_protocol/core/helpers/tables_counters.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/ui/pages/contest/contest_summary_page.dart';

class ContestPage extends StatefulWidget {
  ContestPage({Key key, @required this.contestData}) : super(key: key);
  final Contest contestData;

  @override
  _ContestPageState createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage>
    with TickerProviderStateMixin {
  User _user;
  Contest _contestData;

  int _throwsPerZone;

  bool _isLoading = false;
  bool _isContestContinued = false;

  var _selectedPlayer = <String, dynamic>{};

  var _contestPlayers = <Map<String, dynamic>>[];
  var _playersToPlayOverTime = <Map<String, dynamic>>[];

  Flushbar _flushbar;
  AnimationController _flushbarController;

  @override
  void initState() {
    super.initState();

    _contestData = widget.contestData;
    _contestPlayers = _contestData.players;

    _throwsPerZone = _contestData.throwsPerZone;

    if (_contestData.overtimePlayers != null) {
      _contestPlayers = _contestData.overtimePlayers;

      double _overtimeThrowsNr = _throwsPerZone / 2;
      _throwsPerZone =
          _overtimeThrowsNr.toInt() != 0 ? _overtimeThrowsNr.toInt() + 1 : 1;

      _checkIfContestIsBeingContinuedOrJustStarted(_contestPlayers);
      _shufflePlayers(_contestPlayers);
      _setSelectedPlayer(_contestPlayers);

      return;
    }

    _checkIfContestIsBeingContinuedOrJustStarted(_contestPlayers);
    _shufflePlayers(_contestPlayers);
    _setSelectedPlayer(_contestPlayers);
  }

  @override
  void dispose() {
    super.dispose();

    if (_flushbarController != null) _flushbarController.dispose();
  }

  void _checkIfContestIsBeingContinuedOrJustStarted(
      List<Map<String, dynamic>> _players) {
    for (Map<String, dynamic> _player in _players) {
      if (_player['scored'] + _player['missed'] != 0) {
        _isContestContinued = true;
        return;
      }
    }
  }

  void _shufflePlayers(List<Map<String, dynamic>> _players) {
    if (_isContestContinued) return;

    for (var i = 0; i < 5; i++) _players.shuffle();
  }

  void _setSelectedPlayer(List<Map<String, dynamic>> _players) {
    for (int i = 0; i < _players.length; i++) {
      final _currentPlayer = _players[i];
      final _nextPlayer = _players[i + 1];

      if (_currentPlayer['scored'] + _currentPlayer['missed'] == 0) {
        _selectedPlayer = _currentPlayer;
        return;
      }

      if (_currentPlayer['scored'] + _currentPlayer['missed'] != 0 &&
          _nextPlayer['scored'] + _nextPlayer['missed'] == 0) {
        _selectedPlayer = _nextPlayer;
        return;
      }
    }
  }

  void _verifyThrowsCounterAndAddIfPossible(
      String _zoneScored, String _zoneMissed, bool _isScored) {
    int _zoneThrowsSum =
        _selectedPlayer[_zoneScored] + _selectedPlayer[_zoneMissed];

    if (_zoneThrowsSum < _throwsPerZone) {
      _isScored ? _throwScored(_zoneScored) : _throwMissed(_zoneMissed);
    }
  }

  void _handleThrowButtonClick(
      String _zoneScored, String _zoneMissed, bool _isScored, String _label) {
    bool _isThrowCancelled = false;
    const int _duration = 3;

    if (_flushbar != null) _flushbar.dismiss(true);

    _verifyThrowsCounterAndAddIfPossible(_zoneScored, _zoneMissed, _isScored);

    setState(
      () {
        _flushbarController = AnimationController(
          duration: Duration(seconds: _duration),
          vsync: this,
        );

        _flushbarController.forward();

        _flushbar = buildCustomFlushbar(
          _selectedPlayer['name'],
          _label,
          _duration,
          _flushbarController,
          () {
            _isThrowCancelled = true;

            _flushbar.dismiss(true);
            _flushbarController.dispose();

            _isScored ? _cancelScored(_zoneScored) : _cancelMissed(_zoneMissed);
          },
        )..show(context);
      },
    );

    if (_selectedPlayer['scored'] + _selectedPlayer['missed'] ==
        _throwsPerZone * 5) {
      Future.delayed(
        const Duration(seconds: _duration),
        () {
          if (!_isThrowCancelled) _switchForNextPlayer();
        },
      );
    }
  }

  void _switchForNextPlayer() {
    int _selectedPlayerIndex = _contestPlayers.indexOf(_selectedPlayer);
    int _lastIndex = _contestPlayers.length - 1;

    if (_selectedPlayerIndex == _lastIndex) {
      _finishContest();
      return;
    }

    setState(() => _selectedPlayer = _contestPlayers[_selectedPlayerIndex + 1]);

    _updateContest(false);
    _updateContestDB();
  }

  Future<void> _finishContest() async {
    try {
      if (_checkAndFormOvertimePlayersIfNeeded()) {
        _proceedToOT();
        return;
      }

      _updateContest(true);
      _updateContestDB();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContestSummaryPage(
            contest: _contestData,
          ),
        ),
      );
    } catch (error) {
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _proceedToOT() async {
    try {
      _updateContest(false, _playersToPlayOverTime);
      _updateContestDB();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContestPage(
            contestData: _contestData,
          ),
        ),
      );
    } catch (error) {
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  void _updateContest(bool _isFinished,
      [List<Map<String, dynamic>> _overtimePlayers]) {
    if (_contestData.overtimePlayers != null) {
      _contestData.update({
        'isFinished': _isFinished,
        'overtimePlayers': _overtimePlayers ?? _contestPlayers
      });
      return;
    }

    _contestData.update({
      'isFinished': _isFinished,
      'players': _contestPlayers,
      'overtimePlayers': _overtimePlayers
    });
  }

  Future<void> _updateContestDB() async {
    try {
      setState(() => _isLoading = true);

      ContestDB.updateContestDocument(_user.id, _contestData);

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  bool _checkAndFormOvertimePlayersIfNeeded() {
    int _topScore = 0;

    var _playersToOT = <Map<String, dynamic>>[];
    var _players =
        _contestPlayers.map<Map<String, dynamic>>((player) => player).toList();

    for (int i = 0; i < _players.length; i++) {
      int _currentPlayerScoreCounter = _players[i]['scored'];

      if (_currentPlayerScoreCounter > _topScore) {
        _topScore = _currentPlayerScoreCounter;
      }
    }

    _playersToOT =
        _players.where((player) => player['scored'] == _topScore).toList();

    for (int i = 0; i < _playersToOT.length; i++) {
      final _player = ({
        'name': _playersToOT[i]['name'],
        'scored': 0,
        'missed': 0,
        'zoneOneScored': 0,
        'zoneOneMissed': 0,
        'zoneTwoScored': 0,
        'zoneTwoMissed': 0,
        'zoneThreeScored': 0,
        'zoneThreeMissed': 0,
        'zoneFourScored': 0,
        'zoneFourMissed': 0,
        'zoneFiveScored': 0,
        'zoneFiveMissed': 0,
      });

      _playersToPlayOverTime.add(_player);
    }

    return _playersToPlayOverTime.length >= 2;
  }

  void _cancelScored(String _zoneScored) {
    setState(() {
      _selectedPlayer['scored']--;
      _selectedPlayer[_zoneScored]--;
    });
  }

  void _cancelMissed(String _zoneMissed) {
    setState(() {
      _selectedPlayer['missed']--;
      _selectedPlayer[_zoneMissed]--;
    });
  }

  void _throwScored(String _zoneScored) {
    setState(() {
      _selectedPlayer['scored']++;
      _selectedPlayer[_zoneScored]++;
    });
  }

  void _throwMissed(String _zoneMissed) {
    setState(() {
      _selectedPlayer['missed']++;
      _selectedPlayer[_zoneMissed]++;
    });
  }

  String _sumThrowsFromAllZones(var _player) {
    int _totalThrows = _player['scored'] + _player['missed'];

    return _player['scored'].toString() + '/' + _totalThrows.toString();
  }

  bool _isZoneEnabled(int _zone) {
    int _selectedPlayerThrowsSum =
        _selectedPlayer['scored'] + _selectedPlayer['missed'];

    switch (_zone) {
      case 1:
        return _selectedPlayerThrowsSum < _throwsPerZone;

        break;
      case 2:
        return _throwsPerZone <= _selectedPlayerThrowsSum &&
            _selectedPlayerThrowsSum < _throwsPerZone * 2;
        break;
      case 3:
        return _throwsPerZone * 2 <= _selectedPlayerThrowsSum &&
            _selectedPlayerThrowsSum < _throwsPerZone * 3;
        break;
      case 4:
        return _throwsPerZone * 3 <= _selectedPlayerThrowsSum &&
            _selectedPlayerThrowsSum < _throwsPerZone * 4;
        break;
      case 5:
        return _throwsPerZone * 4 <= _selectedPlayerThrowsSum &&
            _selectedPlayerThrowsSum < _throwsPerZone * 5;
        break;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);

    return WillPopScope(
      onWillPop: () => buildCustomAlertDialog(
        context,
        'contest state saves after each player finishes. you\'ll be able to finish this later.',
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
      child: LoadingOverlay(
        color: Colors.transparent.withOpacity(.8),
        isLoading: _isLoading,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(_contestPlayers),
            bottomNavigationBar: _buildBottomBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            '${_selectedPlayer['name']}: ${_sumThrowsFromAllZones(_selectedPlayer)} - ($_throwsPerZone per zone)',
          ),
        ),
      ),
      bottom: TabBar(
        tabs: <Widget>[
          Tab(
            text: '${_selectedPlayer['name']}',
          ),
          Tab(text: 'summary')
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.home),
        onPressed: () => buildCustomAlertDialog(
          context,
          'contest state saves after each player finishes. you\'ll be able to finish this later.',
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
    );
  }

  Widget _buildBody(List _playersList) {
    return TabBarView(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Column(
              children: _playersList
                  .map<Widget>(
                    (player) => FadeInAnimation(
                      delay: 100,
                      transitionXBegin: 0.0,
                      curve: Curves.ease,
                      child: PlayerBanner(
                        player: player,
                        color: player['name'] == _selectedPlayer['name']
                            ? Themes.getSelectedPlayerColor()
                            : Themes.getTeamTwoColor(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        _buildSummaryView()
      ],
    );
  }

  Widget _buildBottomBar() {
    return Stack(
      children: <Widget>[
        Container(height: 335),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            child: Column(
              children: <Widget>[
                FadeInAnimation(
                  delay: 150,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: _buildThrowZoneContainer(
                    '1st zone:',
                    'zoneOneScored',
                    'zoneOneMissed',
                    _isZoneEnabled(1),
                  ),
                ),
                FadeInAnimation(
                  delay: 300,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: _buildThrowZoneContainer(
                    '2nd zone:',
                    'zoneTwoScored',
                    'zoneTwoMissed',
                    _isZoneEnabled(2),
                  ),
                ),
                FadeInAnimation(
                  delay: 450,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: _buildThrowZoneContainer(
                    '3rd zone:',
                    'zoneThreeScored',
                    'zoneThreeMissed',
                    _isZoneEnabled(3),
                  ),
                ),
                FadeInAnimation(
                  delay: 600,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: _buildThrowZoneContainer(
                    '4th zone:',
                    'zoneFourScored',
                    'zoneFourMissed',
                    _isZoneEnabled(4),
                  ),
                ),
                FadeInAnimation(
                  delay: 750,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: _buildThrowZoneContainer(
                    '5th zone:',
                    'zoneFiveScored',
                    'zoneFiveMissed',
                    _isZoneEnabled(5),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildThrowZoneContainer(String _zoneLabel, String _zoneScored,
      String _zoneMissed, bool _isZoneEnabled) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(125, 255, 125, 1), width: 1),
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4,
              ),
              child: Text(
                _zoneLabel,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomButton(
              key: Key('scoredButton'),
              label: '+scored: ${_selectedPlayer[_zoneScored]}',
              color: Color.fromRGBO(0, 200, 0, 1),
              onClick: _isZoneEnabled
                  ? () => _handleThrowButtonClick(
                        _zoneScored,
                        _zoneMissed,
                        true,
                        'scored',
                      )
                  : null,
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomButton(
              key: Key('missedButton'),
              label: '+missed: ${_selectedPlayer[_zoneMissed]}',
              color: Color.fromRGBO(255, 0, 0, 1),
              onClick: _isZoneEnabled
                  ? () => _handleThrowButtonClick(
                      _zoneScored, _zoneMissed, false, 'missed')
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView() {
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
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('1st zone')),
                      DataColumn(label: Text('2nd zone')),
                      DataColumn(label: Text('3rd zone')),
                      DataColumn(label: Text('4th zone')),
                      DataColumn(label: Text('5th zone')),
                    ],
                    rows: _contestPlayers
                        .map<DataRow>(
                          (player) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  player['name'],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${player['zoneOneScored']}/${player['zoneOneMissed']}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${player['zoneTwoScored']}/${player['zoneTwoMissed']}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${player['zoneThreeScored']}/${player['zoneThreeMissed']}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${player['zoneFourScored']}/${player['zoneFourMissed']}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${player['zoneFiveScored']}/${player['zoneFiveMissed']}',
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
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('total')),
                      DataColumn(label: Text('total %')),
                    ],
                    rows: _contestPlayers
                        .map<DataRow>(
                          (player) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  player['name'],
                                ),
                              ),
                              DataCell(
                                Text(
                                  TablesCounters.throwsTotal(
                                    player,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  TablesCounters.throwsTotalPercentage(
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
          ],
        ),
      ],
    );
  }
}
