import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import 'package:basket_protocol/utils/orientation.dart';
import 'package:basket_protocol/ui/widgets/custom_button.dart';
import 'package:basket_protocol/core/services/auth_service.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/widgets/custom_text_input.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/core/validators/input_validation.dart';

enum ViewMode { login, register, passwordReset }

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailForPasswordResetForm = GlobalKey<FormState>();
  final _emailWithPasswordSignInForm = GlobalKey<FormState>();
  final _emailWithPasswordSignUpForm = GlobalKey<FormState>();

  var viewMode = ViewMode.login;

  var _emailInput = '';
  var _passwordInput = '';
  var _passwordConfirmInput = '';

  bool _isConnected;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  @override
  void initState() {
    super.initState();
    Orientations.lockPortraitMode();
  }

  void _turnLoadingOverlay(bool _turnOn) {
    setState(
      () {
        _isLoading = _turnOn;
      },
    );
  }

  void _validateAndPasswordReset() {
    try {
      var _isFormValid = _emailForPasswordResetForm.currentState.validate();

      if (!_isConnected) throw Exception('no internet connection');
      if (!_isFormValid) return;

      _turnLoadingOverlay(true);

      AuthService().resetPassword(_emailInput);

      _turnLoadingOverlay(false);

      setState(() => viewMode = ViewMode.login);
    } catch (error) {
      _turnLoadingOverlay(false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      if (!_isConnected) throw Exception('no internet connection');

      _turnLoadingOverlay(true);

      await AuthService().signInAnon();

      _turnLoadingOverlay(false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MatchSetupPage(),
        ),
        (route) => false,
      );
    } catch (error) {
      _turnLoadingOverlay(false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (!_isConnected) throw Exception('no internet connection');

      _turnLoadingOverlay(true);

      await AuthService().signWithGoogle();

      _turnLoadingOverlay(false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MatchSetupPage(),
        ),
        (route) => false,
      );
    } catch (error) {
      _turnLoadingOverlay(false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  Future<void> _validateAndSign(bool _isSignInRequested) async {
    try {
      if (!_isConnected) throw Exception('no internet connection');

      var _isFormValid = _isSignInRequested
          ? _emailWithPasswordSignInForm.currentState.validate()
          : _emailWithPasswordSignUpForm.currentState.validate();

      if (!_isFormValid) return;

      _turnLoadingOverlay(true);

      _isSignInRequested
          ? await AuthService()
              .signInWithCredentials(_emailInput, _passwordInput)
          : await AuthService()
              .signUpWithCredentials(_emailInput, _passwordInput);

      _turnLoadingOverlay(false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MatchSetupPage(),
        ),
        (route) => false,
      );
    } catch (error) {
      _turnLoadingOverlay(false);
      buildCustomAlertDialog(context, error.toString());
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    _isConnected = Provider.of<bool>(context);

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
      title: _buildSignInSignUpSwitch(),
    );
  }

  Widget _buildBody() {
    switch (viewMode) {
      case ViewMode.login:
        return _buildSignInView();
        break;

      case ViewMode.register:
        return _buildSignUpView();
        break;

      case ViewMode.passwordReset:
        return _buildResetPasswordView();
        break;

      default:
        return _buildSignInView();
    }
  }

  Widget _buildSignInView() {
    return ListView(
      children: <Widget>[
        Form(
          key: _emailWithPasswordSignInForm,
          child: Column(
            children: <Widget>[
              FadeInAnimation(
                delay: 100,
                transitionXBegin: -200.0,
                curve: Curves.ease,
                child: CustomTextInput(
                  key: Key('signInEmailInput'),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  label: 'email',
                  value: _emailInput,
                  validate: InputValidation.email,
                  onChange: (String input) {
                    _emailInput = input.trim();
                  },
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              FadeInAnimation(
                delay: 100,
                transitionXBegin: -400.0,
                curve: Curves.ease,
                child: CustomTextInput(
                  key: Key('signInPasswordInput'),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  label: 'password',
                  validate: InputValidation.password,
                  onChange: (String input) {
                    _passwordInput = input;
                  },
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: _isPasswordVisible
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                    onPressed: () {
                      setState(
                        () {
                          _isPasswordVisible = !_isPasswordVisible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            FadeInAnimation(
              delay: 100,
              transitionXBegin: -400.0,
              curve: Curves.ease,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      key: Key('resetPasswordButton'),
                      label: 'reset password',
                      isFlatButtonWanted: true,
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(4),
                      onClick: () {
                        setState(
                          () {
                            viewMode = ViewMode.passwordReset;
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            FadeInAnimation(
              delay: 100,
              transitionXBegin: -600.0,
              curve: Curves.ease,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      key: Key('signInButton'),
                      onClick: () {
                        _validateAndSign(true);
                      },
                      label: 'sign in',
                      color: Color.fromRGBO(255, 170, 50, 1),
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FadeInAnimation(
              delay: 100,
              transitionXBegin: -800.0,
              curve: Curves.ease,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12, right: 8),
                      child: Divider(
                        height: 21,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    child: Text(
                      'or',
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 8,
                        right: 12,
                      ),
                      child: Divider(
                        height: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FadeInAnimation(
              delay: 100,
              transitionXBegin: -1000.0,
              curve: Curves.ease,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      key: Key('signInAnonymouslyButton'),
                      onClick: _signInAnonymously,
                      label: 'sign in anonymously',
                      color: Color.fromRGBO(255, 170, 50, 1),
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FadeInAnimation(
              delay: 100,
              transitionXBegin: -1200.0,
              curve: Curves.ease,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 20),
                      child: GoogleSignInButton(
                        key: Key('signInWithGoogleButton'),
                        text: 'sign with google',
                        textStyle: GoogleFonts.getFont(
                          'Ubuntu',
                          fontSize: 16,
                        ),
                        borderRadius: 14,
                        darkMode: true,
                        onPressed: _signInWithGoogle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpView() {
    return ListView(
      children: <Widget>[
        Form(
          key: _emailWithPasswordSignUpForm,
          child: Column(
            children: <Widget>[
              FadeInAnimation(
                delay: 100,
                transitionXBegin: 200.0,
                curve: Curves.ease,
                child: CustomTextInput(
                  key: Key('signUpEmailInput'),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  label: 'email',
                  value: _emailInput,
                  validate: InputValidation.email,
                  onChange: (String input) {
                    _emailInput = input.trim();
                  },
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              FadeInAnimation(
                delay: 100,
                transitionXBegin: 400.0,
                curve: Curves.ease,
                child: CustomTextInput(
                  key: Key('signUpPasswordInput'),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  label: 'password',
                  validate: InputValidation.password,
                  onChange: (String input) {
                    _passwordInput = input;
                  },
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: _isPasswordVisible
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                    onPressed: () {
                      setState(
                        () {
                          _isPasswordVisible = !_isPasswordVisible;
                        },
                      );
                    },
                  ),
                ),
              ),
              FadeInAnimation(
                delay: 100,
                transitionXBegin: 600.0,
                curve: Curves.ease,
                child: CustomTextInput(
                  key: Key('signUpConfirmPasswordInput'),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  label: 'confirm password',
                  validate: (String input) {
                    InputValidation.passwordConfirmation(
                        _passwordConfirmInput, _passwordInput);
                  },
                  onChange: (String input) {
                    _passwordConfirmInput = input;
                  },
                  obscureText: !_isPasswordConfirmVisible,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: _isPasswordConfirmVisible
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                    onPressed: () {
                      setState(
                        () {
                          _isPasswordConfirmVisible =
                              !_isPasswordConfirmVisible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        FadeInAnimation(
          delay: 100,
          transitionXBegin: 800.0,
          curve: Curves.ease,
          child: CustomButton(
            key: Key('signUpButton'),
            onClick: () {
              _validateAndSign(false);
            },
            label: 'sign up',
            color: Color.fromRGBO(255, 170, 50, 1),
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordView() {
    return ListView(
      children: <Widget>[
        Form(
          key: _emailForPasswordResetForm,
          child: FadeInAnimation(
            delay: 100,
            transitionXBegin: 0.0,
            curve: Curves.ease,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: CustomTextInput(
                    key: Key('emailPasswordResetInput'),
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    label: 'email',
                    value: _emailInput,
                    validate: InputValidation.email,
                    onChange: (String input) {
                      _emailInput = input.trim();
                    },
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      key: Key('passwordResetIconButton'),
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _validateAndPasswordReset,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSignInSignUpSwitch() {
    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            key: Key('signInModeButton'),
            onClick: () {
              setState(
                () {
                  viewMode = ViewMode.login;
                },
              );
            },
            label: 'login',
            isFlatButtonWanted: true,
          ),
        ),
        Expanded(
          child: CustomButton(
            key: Key('signUpModeButton'),
            onClick: () {
              setState(
                () {
                  viewMode = ViewMode.register;
                },
              );
            },
            label: 'register',
            isFlatButtonWanted: true,
          ),
        ),
      ],
    );
  }
}
