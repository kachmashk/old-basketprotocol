import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/utils/orientation.dart';
import 'package:basket_protocol/utils/themes/themes.dart';
import 'package:basket_protocol/ui/pages/sign_in_page.dart';
import 'package:basket_protocol/ui/pages/settings_page.dart';
import 'package:basket_protocol/ui/widgets/player_banner.dart';
import 'package:basket_protocol/ui/widgets/custom_button.dart';
import 'package:basket_protocol/ui/pages/development_page.dart';
import 'package:basket_protocol/core/services/auth_service.dart';
import 'package:basket_protocol/ui/widgets/custom_text_input.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/ui/pages/search_activities_page.dart';
import 'package:basket_protocol/core/validators/input_validation.dart';
import 'package:basket_protocol/ui/pages/match/match_confirm_page.dart';
import 'package:basket_protocol/ui/pages/contest/contest_setup_page.dart';

class MatchSetupPage extends StatefulWidget {
  @override
  _MatchSetupPageState createState() => _MatchSetupPageState();
}

class _MatchSetupPageState extends State<MatchSetupPage>
    with SingleTickerProviderStateMixin {
  User _user;
  TabController _tabController;

  String _playerNameInput;
  bool _isLoading = false;

  final _auth = AuthService();

  var _teamOne = <String, dynamic>{};
  var _teamTwo = <String, dynamic>{};

  var _teamOnePlayers = <Map<String, dynamic>>[];
  var _teamTwoPlayers = <Map<String, dynamic>>[];

  final _playerNameController = TextEditingController();

  final _createPlayerTeamOneFormKey = GlobalKey<FormState>();
  final _createPlayerTeamTwoFormKey = GlobalKey<FormState>();

  final _padding =
      const EdgeInsets.only(top: 2, bottom: 8, left: 22, right: 22);

  @override
  void initState() {
    super.initState();

    Orientations.lockPortraitMode();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {});
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
    _playerNameController.dispose();
  }

  void _validateAndProceed() {
    if (_tabController.index == 0) {
      setState(() => _tabController.index = 1);
      return;
    }

    if (_teamOnePlayers.isEmpty || _teamTwoPlayers.isEmpty) {
      buildCustomAlertDialog(context, 'one or both teams are empty');
      return;
    }

    if (_teamOne['name'] == null || _teamOne['name'].isEmpty) {
      _teamOne['name'] = 'team #1';
    }

    if (_teamTwo['name'] == null || _teamTwo['name'].isEmpty) {
      _teamTwo['name'] = 'team #2';
    }

    final _teamOneData = Team(name: _teamOne['name'], players: _teamOnePlayers);
    final _teamTwoData = Team(name: _teamTwo['name'], players: _teamTwoPlayers);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchConfirmPage(
          teamOne: _teamOneData,
          teamTwo: _teamTwoData,
        ),
      ),
    );
  }

  void _createPlayer(String _name, List<Map<String, dynamic>> _teamPlayers,
      GlobalKey<FormState> _formKey) {
    if (!_formKey.currentState.validate()) return;

    final _player = ({
      'name': _name,
      'points': 0,
      'twoPointsMade': 0,
      'twoPointsAttempts': 0,
      'threePointsMade': 0,
      'threePointsAttempts': 0,
      'assists': 0,
      'blocks': 0,
      'rebounds': 0,
      'turnovers': 0,
      'steals': 0
    });

    if (_doesPlayerExist(_player)) {
      _playerNameController.text = '${_player['name']} is already added';
      return;
    }

    setState(() {
      _teamPlayers.add(_player);
      _playerNameController.text = '';
    });
  }

  bool _doesPlayerExist(final _player) {
    if (_teamOnePlayers.firstWhere(
            (player) => player['name'] == _player['name'],
            orElse: () => null) !=
        null) return true;

    if (_teamTwoPlayers.firstWhere(
            (player) => player['name'] == _player['name'],
            orElse: () => null) !=
        null) return true;

    return false;
  }

  void _removePlayer(
      Map<String, dynamic> _player, List<Map<String, dynamic>> _teamPlayers) {
    setState(() => _teamPlayers.remove(_player));
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);

    return DefaultTabController(
      length: 2,
      child: LoadingOverlay(
        color: Colors.transparent.withOpacity(.8),
        isLoading: _isLoading,
        child: Scaffold(
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomButton(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('match setup'),
      actions: <Widget>[
        IconButton(
          onPressed: _validateAndProceed,
          icon: Icon(
            Icons.arrow_forward,
          ),
        )
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            text: (_teamOne['name']?.isEmpty ?? true)
                ? 'team #1'
                : _teamOne['name'],
          ),
          Tab(
            text: (_teamTwo['name']?.isEmpty ?? true)
                ? 'team #2'
                : _teamTwo['name'],
          )
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 500,
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.looks_3),
              title: Text('play 3 points contest'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContestSetupPage(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('contest history'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchActivitiesPage(
                    userId: _user.id,
                    collection: 'contests',
                  ),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('matches history'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchActivitiesPage(
                    userId: _user.id,
                    collection: 'matches',
                  ),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.unarchive),
              title: Text('unfinished activities'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchActivitiesPage(
                    userId: _user.id,
                    isUnfinishedActivitiesViewEnabled: true,
                  ),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('settings'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              ),
            ),
            Divider(),
            _user != null && _user.email != null
                ? ListTile(
                    leading: Icon(Icons.cancel),
                    title: Text('sign out'),
                    onTap: () async {
                      setState(() => _isLoading = true);
                      Navigator.pop(context);

                      await _auth.signOut(context);

                      setState(() => _isLoading = false);

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                          (route) => false);
                    },
                  )
                : ListTile(
                    leading: Icon(Icons.cancel),
                    title: Text('delete account'),
                    onTap: () async {
                      setState(() => _isLoading = true);
                      Navigator.pop(context);

                      final _currentUser =
                          await FirebaseAuth.instance.currentUser();
                      await _auth.deleteAccount(_currentUser);

                      setState(() => _isLoading = false);

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                          (route) => false);
                    },
                  ),
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DevelopmentPage(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'BasketProtocol 0.9.5',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        _buildTeamsView(1),
        _buildTeamsView(2),
      ],
    );
  }

  Widget _buildTeamsView(int _teamNr) {
    Color _color;
    String _label;
    Map<String, dynamic> _team;
    List<Map<String, dynamic>> _teamPlayers;
    double _playerBannerTransitionXBegin;

    var _formKey = GlobalKey<FormState>();

    switch (_teamNr) {
      case 1:
        {
          _label = 'team #1 name';
          _teamPlayers = _teamOnePlayers;
          _team = _teamOne;
          _color = Themes.getTeamOneColor();
          _formKey = _createPlayerTeamOneFormKey;
          _playerBannerTransitionXBegin = -200.0;
        }
        break;

      case 2:
        {
          _label = 'team #2 name';
          _teamPlayers = _teamTwoPlayers;
          _team = _teamTwo;
          _color = Themes.getTeamTwoColor();
          _formKey = _createPlayerTeamTwoFormKey;
          _playerBannerTransitionXBegin = 200.0;
        }
        break;
    }

    return ListView(
      children: <Widget>[
        Padding(
          padding: _padding,
          child: FadeInAnimation(
            delay: 150,
            transitionXBegin: 0.0,
            curve: Curves.easeOut,
            child: CustomTextInput(
              label: _label,
              value: _team['name']?.isEmpty ?? true ? null : _team['name'],
              validate: InputValidation.allowOnlyLettersAndSpaces,
              onChange: (String input) => setState(
                () => _team['name'] = input.trim(),
              ),
            ),
          ),
        ),
        Column(
          children: _teamPlayers
              .map<Widget>(
                (player) => FadeInAnimation(
                  delay: 150,
                  transitionXBegin: _playerBannerTransitionXBegin,
                  curve: Curves.ease,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: PlayerBanner(
                          player: player,
                          color: _color,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () =>
                                _removePlayer(player, _teamPlayers),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        Padding(
          padding: _padding,
          child: FadeInAnimation(
            delay: 300,
            transitionXBegin: 0.0,
            curve: Curves.easeOut,
            child: Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: CustomTextInput(
                      formController: _playerNameController,
                      label: 'player name',
                      validate: InputValidation.allowOnlyLettersAndSpaces,
                      onChange: (String input) =>
                          _playerNameInput = input.trim(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _playerNameController.text = '',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () => _createPlayer(
                        _playerNameInput,
                        _teamPlayers,
                        _formKey,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            key: Key('clearTeamsButton'),
            margin: const EdgeInsets.all(12),
            isFlatButtonWanted: true,
            label: 'clear teams data',
            onClick: () => setState(
              () {
                _teamOne = <String, dynamic>{};
                _teamTwo = <String, dynamic>{};

                _teamOnePlayers = <Map<String, dynamic>>[];
                _teamTwoPlayers = <Map<String, dynamic>>[];

                _tabController.index = 0;
              },
            ),
          ),
        ),
      ],
    );
  }
}
