import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/utils/themes/themes.dart';
import 'package:basket_protocol/ui/pages/sign_in_page.dart';
import 'package:basket_protocol/utils/themes/theme_changer.dart';
import 'package:basket_protocol/core/services/auth_service.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/core/services/connection_service.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license =
        await rootBundle.loadString('lib/assets/fonts/Ubuntu/OFL.txt');
    yield LicenseEntryWithLineBreaks(['lib/assets/fonts/Ubuntu'], license);
  });

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        builder: (context) => ThemeChanger(Themes.getDarkTheme()),
        child: Providers());
  }
}

class Providers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <StreamProvider>[
        StreamProvider<bool>(
            builder: (context) => ConnectionService().connection),
        StreamProvider<User>(builder: (context) => AuthService().user),
      ],
      child: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.getTheme(),
      home: user == null ? SignInPage() : MatchSetupPage(),
    );
  }
}
