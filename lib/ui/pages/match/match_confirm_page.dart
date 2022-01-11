import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/core/db/match_db.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/utils/themes/themes.dart';
import 'package:basket_protocol/ui/widgets/player_banner.dart';
import 'package:basket_protocol/ui/pages/match/match_page.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_text_input.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/core/validators/input_validation.dart';

enum MatchModeSetting { short, fullPoints, fullMinutes }

class MatchConfirmPage extends StatefulWidget {
  MatchConfirmPage({Key key, @required this.teamOne, @required this.teamTwo})
      : super(key: key);
  final Team teamOne;
  final Team teamTwo;

  @override
  _MatchConfirmPageState createState() => _MatchConfirmPageState();
}

class _MatchConfirmPageState extends State<MatchConfirmPage> {
  User _user;

  String _gameRule;
  String _gameMode;
  String _venueInput;
  int _gameRuleValueInput;

  bool _isLoading = false;

  MatchModeSetting _matchMode = MatchModeSetting.fullMinutes;

  final _confirmationTabFormKey = GlobalKey<FormState>();

  Future<void> _validateAndProceed() async {
    if (!_confirmationTabFormKey.currentState.validate()) return;

    try {
      switch (_matchMode) {
        case MatchModeSetting.fullMinutes:
          {
            _gameRule = 'minutes';
            _gameMode = 'full';
          }
          break;

        case MatchModeSetting.fullPoints:
          {
            _gameRule = 'points';
            _gameMode = 'full';
          }
          break;

        case MatchModeSetting.short:
          {
            _gameRule = 'points';
            _gameMode = 'short';
          }
          break;
      }

      setState(() => _isLoading = true);

      final _matchData = Match(
          venue: _venueInput,
          gameRule: _gameRule,
          gameMode: _gameMode,
          gameRuleValue: _gameRuleValueInput,
          teamOne: widget.teamOne,
          teamTwo: widget.teamTwo);

      final _createdMatch = MatchDB.createMatchDocument(_user.id, _matchData);

      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchPage(
            matchData: _createdMatch,
          ),
        ),
      );
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
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
      title: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            '${widget.teamOne.name} vs ${widget.teamTwo.name}',
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: _validateAndProceed,
          icon: Icon(
            Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: _confirmationTabFormKey,
      child: ListView(
        children: <Widget>[
          FadeInAnimation(
            delay: 150,
            transitionXBegin: -100.0,
            curve: Curves.easeOut,
            child: ExpansionTile(
              title: Text('${widget.teamOne.name} - players:'),
              children: widget.teamOne.players
                  .map<Widget>(
                    (player) => PlayerBanner(
                      player: player,
                      color: Themes.getTeamOneColor(),
                    ),
                  )
                  .toList(),
            ),
          ),
          FadeInAnimation(
            delay: 250,
            transitionXBegin: -100.0,
            curve: Curves.easeOut,
            child: ExpansionTile(
              title: Text('${widget.teamTwo.name} - players:'),
              children: widget.teamTwo.players
                  .map<Widget>(
                    (player) => PlayerBanner(
                      player: player,
                      color: Themes.getTeamTwoColor(),
                    ),
                  )
                  .toList(),
            ),
          ),
          Divider(
            indent: 21,
            endIndent: 21,
          ),
          FadeInAnimation(
            delay: 150,
            transitionXBegin: 0.0,
            curve: Curves.easeIn,
            child: ListTile(
              title: CustomTextInput(
                label: 'venue',
                hintText: 'jedynka square garden',
                validate: InputValidation.allowOnlyLettersAndSpaces,
                onChange: (String input) => _venueInput = input.trim(),
              ),
            ),
          ),
          FadeInAnimation(
            delay: 200,
            transitionXBegin: 150.0,
            curve: Curves.easeIn,
            child: GestureDetector(
              onTap: () => setState(
                () => _matchMode = MatchModeSetting.fullMinutes,
              ),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Radio(
                      value: MatchModeSetting.fullMinutes,
                      groupValue: _matchMode,
                      onChanged: (MatchModeSetting value) => setState(
                        () => _matchMode = value,
                      ),
                    ),
                    Text('classic full game')
                  ],
                ),
              ),
            ),
          ),
          FadeInAnimation(
            delay: 400,
            transitionXBegin: 150.0,
            curve: Curves.easeIn,
            child: GestureDetector(
              onTap: () => setState(
                () => _matchMode = MatchModeSetting.fullPoints,
              ),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Radio(
                      value: MatchModeSetting.fullPoints,
                      groupValue: _matchMode,
                      onChanged: (MatchModeSetting value) => setState(
                        () => _matchMode = value,
                      ),
                    ),
                    Text('full game with points per quarter rule')
                  ],
                ),
              ),
            ),
          ),
          FadeInAnimation(
            delay: 600,
            transitionXBegin: 150.0,
            curve: Curves.easeIn,
            child: GestureDetector(
              onTap: () => setState(() => _matchMode = MatchModeSetting.short),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Radio(
                      value: MatchModeSetting.short,
                      groupValue: _matchMode,
                      onChanged: (MatchModeSetting value) => setState(
                        () => _matchMode = value,
                      ),
                    ),
                    Text('one quarter only')
                  ],
                ),
              ),
            ),
          ),
          FadeInAnimation(
            delay: 150,
            transitionXBegin: 0.0,
            curve: Curves.bounceIn,
            child: ListTile(
              title: _buildMatchRuleAndSettingInput(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRuleAndSettingInput() {
    switch (_matchMode) {
      case MatchModeSetting.fullMinutes:
        return CustomTextInput(
          label: 'minutes per quarter',
          hintText: '12',
          suffixText: 'minutes',
          maxLength: 2,
          keyboardType: TextInputType.number,
          validate: InputValidation.allowNumbersOnly,
          onChange: (String input) => setState(
            () => _gameRuleValueInput = int.parse(
              input.trim(),
            ),
          ),
        );
        break;

      case MatchModeSetting.fullPoints:
        return CustomTextInput(
          label: 'points per quarter',
          hintText: '30',
          suffixText: 'points',
          maxLength: 2,
          keyboardType: TextInputType.number,
          validate: InputValidation.allowNumbersOnly,
          onChange: (String input) => setState(
            () => _gameRuleValueInput = int.parse(
              input.trim(),
            ),
          ),
        );
        break;

      case MatchModeSetting.short:
        return CustomTextInput(
          label: 'target points',
          hintText: '21',
          suffixText: 'points',
          maxLength: 2,
          keyboardType: TextInputType.number,
          validate: InputValidation.allowNumbersOnly,
          onChange: (String input) => setState(
            () => _gameRuleValueInput = int.parse(
              input.trim(),
            ),
          ),
        );
        break;

      default:
        return null;
    }
  }
}
