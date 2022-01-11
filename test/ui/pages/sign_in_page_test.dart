// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';

// import 'package:basket_protocol/core/models/user.dart';
// import 'package:basket_protocol/utils/themes/themes.dart';
// import 'package:basket_protocol/ui/pages/sign_in_page.dart';
// import 'package:basket_protocol/core/services/auth_service.dart';
// import 'package:basket_protocol/utils/themes/theme_changer.dart';

// class MockAuthService extends Mock implements AuthService {}

// void main() {
//   Widget _buildOnlineTestableWidget({Widget child}) {
//     return ChangeNotifierProvider<ThemeChanger>(
//       builder: (context) => ThemeChanger(
//         Themes.getDarkTheme(),
//       ),
//       child: MultiProvider(
//         providers: <StreamProvider>[
//           StreamProvider<bool>(
//             builder: (context) => Stream<bool>.value(true),
//           ),
//           StreamProvider<User>(
//             builder: (context) => MockAuthService().user,
//           ),
//         ],
//         child: MaterialApp(
//           home: child,
//         ),
//       ),
//     );
//   }

//   Widget _buildOfflineTestableWidget({Widget child}) {
//     return ChangeNotifierProvider<ThemeChanger>(
//       builder: (context) => ThemeChanger(
//         Themes.getDarkTheme(),
//       ),
//       child: MultiProvider(
//         providers: <StreamProvider>[
//           StreamProvider<bool>(
//             builder: (context) => Stream<bool>.value(false),
//           ),
//           StreamProvider<User>(
//             builder: (context) => MockAuthService().user,
//           ),
//         ],
//         child: MaterialApp(
//           home: child,
//         ),
//       ),
//     );
//   }

//   group(
//     'SignInPage build ->',
//     () {
//       testWidgets(
//         'verify sign in mode render',
//         (WidgetTester tester) async {
//           SignInPage _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('signInEmailInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('resetPasswordButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInAnonymouslyButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInWithGoogleButton')),
//             findsOneWidget,
//           );
//         },
//       );

//       testWidgets(
//         'verify sign up mode render',
//         (WidgetTester tester) async {
//           SignInPage _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpModeButton')));
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('signUpEmailInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpConfirmPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpButton')),
//             findsOneWidget,
//           );
//         },
//       );

//       testWidgets(
//         'verify password reset mode render',
//         (WidgetTester tester) async {
//           SignInPage _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('resetPasswordButton')));
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('emailPasswordResetInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('passwordResetIconButton')),
//             findsOneWidget,
//           );
//         },
//       );

//       testWidgets(
//         'change mode to reset password, back to sign in & to the sign up mode',
//         (WidgetTester tester) async {
//           SignInPage _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('signInEmailInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('resetPasswordButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInAnonymouslyButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInWithGoogleButton')),
//             findsOneWidget,
//           );

//           await tester.tap(find.byKey(Key('resetPasswordButton')));
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('emailPasswordResetInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('passwordResetIconButton')),
//             findsOneWidget,
//           );

//           await tester.tap(find.byKey(Key('signInModeButton')));
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('signInEmailInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('resetPasswordButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInAnonymouslyButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signInWithGoogleButton')),
//             findsOneWidget,
//           );

//           await tester.tap(find.byKey(Key('signUpModeButton')));
//           await tester.pumpAndSettle();

//           expect(
//             find.byKey(Key('signInModeButton')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpModeButton')),
//             findsOneWidget,
//           );

//           expect(
//             find.byKey(Key('signUpEmailInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpConfirmPasswordInput')),
//             findsOneWidget,
//           );
//           expect(
//             find.byKey(Key('signUpButton')),
//             findsOneWidget,
//           );
//         },
//       );
//     },
//   );

//   group(
//     'Offline SignInPage =>',
//     () {
//       testWidgets(
//         'sign in -> should throw \'no internet connection\' exception',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();
//           await tester.tap(find.byKey(Key('signInButton')));

//           expect(
//             tester.takeException(),
//             isInstanceOf<Exception>(),
//           );

//           verifyNever(_mockAuth.signInWithCredentials('', ''));
//         },
//       );

//       testWidgets(
//         'sign up -> should throw \'no internet connection\' exception',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpModeButton')));
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpButton')));

//           expect(tester.takeException(), isInstanceOf<Exception>());

//           verifyNever(
//             _mockAuth.signUpWithCredentials('', ''),
//           );
//         },
//       );

//       testWidgets(
//         'sign in anonymously -> should throw \'no internet connection\' exception',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();
//           await tester.tap(find.byKey(Key('signInAnonymouslyButton')));

//           expect(tester.takeException(), isInstanceOf<Exception>());

//           verifyNever(
//             _mockAuth.signInAnon(),
//           );
//         },
//       );

//       testWidgets(
//         'sign with google -> should throw \'no internet connection\' exception',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOfflineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();
//           await tester.tap(find.byKey(Key('signInWithGoogleButton')));

//           expect(tester.takeException(), isInstanceOf<Exception>());

//           verifyNever(
//             _mockAuth.signWithGoogle(),
//           );
//         },
//       );
//     },
//   );

//   group(
//     'Online SignInPage =>',
//     () {
//       testWidgets(
//         'should not sign up, email & password are empty',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOnlineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpModeButton')));
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpButton')));

//           verifyNever(
//             _mockAuth.signUpWithCredentials('', ''),
//           );
//         },
//       );

//       testWidgets(
//         'should not sign up, password confirmation is wrong',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOnlineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpModeButton')));
//           await tester.pumpAndSettle();

//           var _email = 'test@mail.com';
//           var _password = '123123123';
//           var _passwordConfirmation = 'XD';

//           var _emailInput = find.byKey(Key('signUpEmailInput'));
//           var _passwordInput = find.byKey(Key('signUpPasswordInput'));
//           var _passwordConfirmInput =
//               find.byKey(Key('signUpConfirmPasswordInput'));

//           await tester.enterText(_emailInput, _email);
//           await tester.enterText(_passwordInput, _password);
//           await tester.enterText(_passwordConfirmInput, _passwordConfirmation);

//           await tester.tap(find.byKey(Key('signUpButton')));

//           verifyNever(
//             _mockAuth.signUpWithCredentials(_email, _password),
//           );
//         },
//       );

//       testWidgets(
//         'should sign up with passed email & password',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOnlineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signUpModeButton')));
//           await tester.pumpAndSettle();

//           var _email = 'test@mail.com';
//           var _password = '123123123';
//           var _passwordConfirmation = '123123123';

//           var _emailInput = find.byKey(Key('signUpEmailInput'));
//           var _passwordInput = find.byKey(Key('signUpPasswordInput'));
//           var _passwordConfirmInput =
//               find.byKey(Key('signUpConfirmPasswordInput'));

//           await tester.enterText(_emailInput, _email);
//           await tester.enterText(_passwordInput, _password);
//           await tester.enterText(_passwordConfirmInput, _passwordConfirmation);

//           await tester.tap(find.byKey(Key('signUpButton')));

//           verify(
//             _mockAuth.signUpWithCredentials(_email, _password),
//           ).called(1);
//         },
//       );

//       testWidgets(
//         'should not sign in, email & password are empty',
//         (WidgetTester tester) async {
//           var _mockAuth = MockAuthService();
//           var _signInPage = SignInPage();

//           await tester.pumpWidget(
//             _buildOnlineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();
//           await tester.tap(find.byKey(Key('signInButton')));

//           verifyNever(
//             _mockAuth.signInWithCredentials('', ''),
//           );
//         },
//       );

//       testWidgets(
//         'should sign in with passed email & password',
//         (WidgetTester tester) async {
//           final _mockAuth = MockAuthService();
//           final _signInPage = SignInPage();

//           final _email = 'oskar.kaczmarzyk@tuta.io';
//           final _password = '123123123';

//           when(
//             _mockAuth.signInWithCredentials(_email, _password),
//           ).thenAnswer(null);

//           await tester.pumpWidget(
//             _buildOnlineTestableWidget(
//               child: _signInPage,
//             ),
//           );
//           await tester.pumpAndSettle();

//           final emailInput = find.byKey(Key('signInEmailInput'));
//           final passwordInput = find.byKey(Key('signInPasswordInput'));

//           await tester.enterText(emailInput, _email);
//           await tester.enterText(passwordInput, _password);

//           await tester.tap(find.byKey(Key('signInButton')));

//           verify(
//             _mockAuth.signInWithCredentials(_email, _password),
//           ).called(1);
//         },
//       );

//       testWidgets(
//         'should sign in anonymously',
//         (WidgetTester tester) async {
//           when(MockAuthService().signInAnon()).thenAnswer(null);

//           await tester.pumpWidget(
//             _buildOnlineTestableWidget(
//               child: SignInPage(),
//             ),
//           );
//           await tester.pumpAndSettle();

//           await tester.tap(find.byKey(Key('signInAnonymouslyButton')));

//           verify(MockAuthService().signInAnon()).called(1);
//         },
//       );
//     },
//   );
// }

void main() {}
