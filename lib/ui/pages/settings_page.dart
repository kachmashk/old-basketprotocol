import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/utils/themes/themes.dart';
import 'package:basket_protocol/ui/pages/sign_in_page.dart';
import 'package:basket_protocol/ui/widgets/custom_button.dart';
import 'package:basket_protocol/utils/themes/theme_changer.dart';
import 'package:basket_protocol/core/services/auth_service.dart';
import 'package:basket_protocol/ui/widgets/custom_text_input.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/core/validators/input_validation.dart';

enum Theme { light, dark, amoled }

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User _user;
  Theme _themes;
  ThemeChanger _themeChanger;

  final _auth = AuthService();

  String _emailInput;
  String _usernameInput;

  bool _isConnected;
  bool _isLoading = false;

  final _updateProfileFormKey = GlobalKey<FormState>();

  Future<void> _updateUserData() async {
    if (!_isConnected) {
      buildCustomAlertDialog(context, 'no internet connection');
      return;
    }

    final _currentUser = await FirebaseAuth.instance.currentUser();

    if (!_updateProfileFormKey.currentState.validate()) return;

    try {
      setState(() => _isLoading = true);

      if (_emailInput != null &&
          _emailInput != _user.email &&
          _usernameInput != null &&
          _usernameInput != _user.name) {
        await _auth.updateUserName(_currentUser, _usernameInput);
        await _auth.updateUserEmail(_currentUser, _emailInput);

        _buildUserUpdateDialog();
        setState(() => _isLoading = false);
        return;
      }

      if (_emailInput != null && _emailInput != _user.email) {
        await _auth.updateUserEmail(_currentUser, _emailInput);

        _buildUserUpdateDialog();
        setState(() => _isLoading = false);
        return;
      }

      if (_usernameInput != null && _usernameInput != _user.name) {
        await _auth.updateUserName(_currentUser, _usernameInput);

        _buildUserUpdateDialog();
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (!_isConnected) {
      buildCustomAlertDialog(context, 'no internet connection');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final _user = await FirebaseAuth.instance.currentUser();
      await _auth.verifyUserEmail(_user);

      buildCustomAlertDialog(
        context,
        'please logout & login to commit changes',
        CustomButton(
          key: Key('logoutButton'),
          label: 'logout',
          isFlatButtonWanted: true,
          onClick: _signOut,
        ),
      );

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _signOut() async {
    if (!_isConnected) {
      buildCustomAlertDialog(context, 'no internet connection');
      return;
    }

    try {
      setState(() => _isLoading = true);
      Navigator.pop(context);

      await _auth.signOut(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
        (route) => false,
      );

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _deleteAccount() async {
    if (!_isConnected) {
      buildCustomAlertDialog(context, 'no internet connection');
      return;
    }

    try {
      setState(() => _isLoading = true);
      Navigator.pop(context);

      final _user = await FirebaseAuth.instance.currentUser();
      await _auth.deleteAccount(_user);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
        (route) => false,
      );

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  void _handleThemeChange(final _theme) {
    setState(
      () {
        switch (_theme) {
          case Theme.light:
            {
              _themes = Theme.light;
              _themeChanger.setTheme(Themes.getLightTheme());
            }
            break;

          case Theme.dark:
            {
              _themes = Theme.dark;
              _themeChanger.setTheme(Themes.getDarkTheme());
            }
            break;

          case Theme.amoled:
            {
              _themes = Theme.amoled;
              _themeChanger.setTheme(Themes.getAmoledTheme());
            }
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    _isConnected = Provider.of<bool>(context);
    _themeChanger = Provider.of<ThemeChanger>(context);

    switch (_themeChanger.getTheme().scaffoldBackgroundColor.value) {
      case 4294638330:
        _themes = Theme.light;
        break;

      case 4281348144:
        _themes = Theme.dark;
        break;

      case 4278190080:
        _themes = Theme.amoled;
        break;
    }

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
      title: Text('settings'),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        ExpansionTile(
          title: Text('themes'),
          children: <Widget>[
            GestureDetector(
              onTap: () => _handleThemeChange(Theme.light),
              child: Row(
                children: <Widget>[
                  Radio(
                    value: Theme.light,
                    groupValue: _themes,
                    onChanged: (Theme _theme) => _handleThemeChange(
                      _theme,
                    ),
                  ),
                  Text('light theme')
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _handleThemeChange(Theme.dark),
              child: Row(
                children: <Widget>[
                  Radio(
                    value: Theme.dark,
                    groupValue: _themes,
                    onChanged: (Theme _theme) => _handleThemeChange(
                      _theme,
                    ),
                  ),
                  Text('dark theme')
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _handleThemeChange(Theme.amoled),
              child: Row(
                children: <Widget>[
                  Radio(
                    value: Theme.amoled,
                    groupValue: _themes,
                    onChanged: (Theme _theme) => _handleThemeChange(
                      _theme,
                    ),
                  ),
                  Text('amoled theme')
                ],
              ),
            ),
          ],
        ),
        Divider(
          indent: 21,
          endIndent: 21,
        ),
        _user.email == null
            ? Center(
                child: Text(
                  'account settings not available with anonymous authentication.',
                  textAlign: TextAlign.center,
                ),
              )
            : _user.isEmailVerified
                ? _buildProfileUpdateView()
                : _buildEmailVerifyView()
      ],
    );
  }

  Widget _buildEmailVerifyView() {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(4),
          child: Text(
              'you cannot edit your profile until you\'ll confirm an email.',
              textAlign: TextAlign.center),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(4),
          child: Text('if you\'ve done it please logout & login.',
              textAlign: TextAlign.center),
        ),
        CustomButton(
          key: Key('sendVerificatuinEmailButton'),
          onClick: _sendVerificationEmail,
          label: 'send verification email',
          isFlatButtonWanted: true,
          color: Color.fromRGBO(
            55,
            255,
            255,
            1,
          ),
        ),
        CustomButton(
          key: Key('logoutButton'),
          onClick: _signOut,
          label: 'logout',
          isFlatButtonWanted: true,
        ),
      ],
    );
  }

  Widget _buildProfileUpdateView() {
    return Form(
      key: _updateProfileFormKey,
      child: Column(
        children: <Widget>[
          FadeInAnimation(
            delay: 0,
            transitionXBegin: -300.0,
            curve: Curves.decelerate,
            child: CustomTextInput(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              label: 'username',
              value: _user.name,
              validate: InputValidation.allowOnlyLettersAndSpaces,
              onChange: (String input) => _usernameInput = input.trim(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          FadeInAnimation(
            delay: 0,
            transitionXBegin: 300.0,
            curve: Curves.decelerate,
            child: CustomTextInput(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              label: 'email',
              value: _user.email,
              validate: InputValidation.email,
              onChange: (String input) => _emailInput = input.trim(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.alternate_email),
            ),
          ),
          FadeInAnimation(
            delay: 0,
            transitionXBegin: -300.0,
            curve: Curves.decelerate,
            child: CustomButton(
              key: Key('updateAccountDataButton'),
              onClick: _updateUserData,
              label: 'update account data',
              isFlatButtonWanted: true,
            ),
          ),
          Divider(
            indent: 21,
            endIndent: 21,
          ),
          FadeInAnimation(
            delay: 0,
            transitionXBegin: 300.0,
            curve: Curves.decelerate,
            child: CustomButton(
              key: Key('openDeleteAccountDialogButton'),
              onClick: () => buildCustomAlertDialog(
                context,
                'you\'ll wipe all your data. are you sure?',
                CustomButton(
                  key: Key('deleteAccountButton'),
                  label: 'delete',
                  isFlatButtonWanted: true,
                  onClick: _deleteAccount,
                ),
              ),
              label: 'delete account',
              isFlatButtonWanted: true,
            ),
          )
        ],
      ),
    );
  }

  Future<Widget> _buildUserUpdateDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('to see update you have to logout & login'),
          actions: <Widget>[
            CustomButton(
              key: Key('goToHomePageButton'),
              onClick: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchSetupPage(),
                ),
                (route) => false,
              ),
              label: 'go to home page',
              isFlatButtonWanted: true,
            ),
            CustomButton(
              key: Key('logoutButton'),
              onClick: _signOut,
              label: 'logout',
              isFlatButtonWanted: true,
            ),
          ],
        );
      },
    );
  }
}
