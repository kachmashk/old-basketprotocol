import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/core/db/contest_db.dart';
import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/ui/widgets/player_banner.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_text_input.dart';
import 'package:basket_protocol/ui/pages/contest/contest_page.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/core/validators/input_validation.dart';

class ContestSetupPage extends StatefulWidget {
  @override
  _ContestSetupPageState createState() => _ContestSetupPageState();
}

class _ContestSetupPageState extends State<ContestSetupPage> {
  User _user;

  String _venueInput;
  String _playerNameInput;

  int _throwsPerZoneInput;

  bool _isLoading = false;

  var _contestPlayers = <Map<String, dynamic>>[];

  final _contestInfoFormKey = GlobalKey<FormState>();
  final _createPlayerFormKey = GlobalKey<FormState>();

  final _playerNameController = TextEditingController();

  Future<void> _validateAndProceed() async {
    if (_contestPlayers.isEmpty || _contestPlayers.length == 1) {
      buildCustomAlertDialog(context, 'you need to add at least 2 players');
      return;
    }

    if (!_contestInfoFormKey.currentState.validate()) return;

    try {
      setState(() => _isLoading = true);

      final _contestData = Contest(
          venue: _venueInput,
          throwsPerZone: _throwsPerZoneInput,
          players: _contestPlayers);

      final _createdContest =
          ContestDB.createContestDocument(_user.id, _contestData);

      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContestPage(
            contestData: _createdContest,
          ),
        ),
      );
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  void _createPlayer(String _name) {
    if (!_createPlayerFormKey.currentState.validate()) return;

    final _player = ({
      'name': _name,
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

    if (_contestPlayers.firstWhere(
            (player) => player['name'] == _player['name'],
            orElse: () => null) !=
        null) {
      _playerNameController.text = '${_player['name']} already added';

      return;
    }

    setState(() {
      _contestPlayers.add(_player);
      _playerNameController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);

    return LoadingOverlay(
      color: Colors.transparent.withOpacity(.8),
      isLoading: _isLoading,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('setup 3pts contest'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_forward),
          tooltip: 'submit and play',
          onPressed: _validateAndProceed,
        )
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        Form(
          key: _contestInfoFormKey,
          child: FadeInAnimation(
            delay: 200,
            transitionXBegin: 0.0,
            curve: Curves.easeOut,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: CustomTextInput(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    label: 'venue',
                    hintText: 'l.a. venice beach',
                    validate: InputValidation.allowOnlyLettersAndSpaces,
                    onChange: (String input) => _venueInput = input.trim(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomTextInput(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    label: 'throws per zone',
                    hintText: '5',
                    keyboardType: TextInputType.number,
                    validate: InputValidation.allowNumbersOnly,
                    onChange: (String input) => _throwsPerZoneInput = int.parse(
                      input.trim(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          children: _contestPlayers
              .map<Widget>(
                (_player) => FadeInAnimation(
                  delay: 200,
                  transitionXBegin: 0.0,
                  curve: Curves.easeOut,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: PlayerBanner(
                          player: _player,
                          color: Color.fromRGBO(255, 170, 50, 1),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => setState(
                              () => _contestPlayers.remove(
                                _player,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        FadeInAnimation(
          delay: 400,
          transitionXBegin: 0.0,
          curve: Curves.easeOut,
          child: Row(
            children: <Widget>[
              Form(
                key: _createPlayerFormKey,
                child: Expanded(
                  flex: 5,
                  child: CustomTextInput(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    formController: _playerNameController,
                    label: 'player name',
                    validate: InputValidation.allowOnlyLettersAndSpaces,
                    onChange: (String input) => _playerNameInput = input.trim(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _playerNameController.text = '',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () => _createPlayer(
                      _playerNameInput,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
