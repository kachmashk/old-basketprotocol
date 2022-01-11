# Table of Contents - BasketProtocol v0.9.5
1. [About](#About)
2. [Used packages](#Used-packages)
3. [Screenshots](#Screenshots)
4. [ToDo](#ToDo)
5. [License](https://github.com/kachmashk/BasketProtocol/blob/develop/LICENSE)

## About
My mobile solution for an old idea of making basketball protocols finally coming to be real thing with Flutter.
Until this time I've had in mind just 3 points contests & casual games so you won't see seperated rebounds for defense & offense, players substitutions or fouls and free throws.
All of that should be added in the future for the release. You can look up everything in ToDo section.

## Used packages
  - simple_animations (https://pub.dev/packages/simple_animations)
  - provider (https://pub.dev/packages/provider)
  - loading_overlay (https://pub.dev/packages/loading_overlay)
  - flutter_auth_buttons (https://pub.dev/packages/flutter_auth_buttons)
  - firebase_auth (https://pub.dev/packages/firebase_auth)
  - cloud_firestore (https://pub.dev/packages/cloud_firestore)
  - google_sign_in (https://pub.dev/packages/google_sign_in)
  - google_fonts (https://pub.dev/packages/google_fonts)
  - flushbar (https://pub.dev/packages/flushbar)
  - connectivity (https://pub.dev/packages/connectivity)
  - firebase_auth_mocks (https://pub.dev/packages/firebase_auth_mocks)
  - cloud_firestore_mocks (https://pub.dev/packages/cloud_firestore_mocks)
  - mockito (https://pub.dev/packages/mockito)

## Screenshots
| Sign In | 3PTS Contest Setup | 3PTS Contest | Summary During 3PTS Contest |
| ----------- | ----------- | ----------- | ----------- |
| ![Sign In](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/Sign%20In.png?token=ADIPES5LLACU2CDPTA37YUS7TQSKE) | ![3PTS Contest Setup](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/contests/3PTS%20Contest%20Setup.png?token=ADIPESZILJ274PB65TUWSW27TQSOQ) | ![3PTS Contest](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/contests/3PTS%20Contest.png?token=ADIPES2MY44FMFGQXMR536S7TQSOS) | ![Summary During 3PTS Contest](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/contests/Summary%20During%20Contest.png?token=ADIPES2UQYNC3YCJDXLD4NS7TQSOW)

| Match Squads Setup | Match Settings Setup | Match | Summary During Match |
| ----------- | ----------- | ----------- | ----------- | 
| ![Match Squads Setup](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/matches/Match%20Squad.png?token=ADIPESZABT26KJFRV232VC27TQS4U) | ![Match Settings Setup](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/matches/Math%20Confirm.png?token=ADIPES6HPOGVBLQLCI6XJAC7TQS4Y) | ![Match](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/matches/Match.png?token=ADIPESZJZVXQ6FQXAOUFVY27TQS42) | ![Summary During Match](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/matches/Summary%20During%20Match.png?token=ADIPES2VMEH3X6WLHLVKGHK7TQS44)

| Activities Search | 3PTS Contest Summary | Match Summary |
| ----------- | ----------- | ----------- |
| ![Activities Search](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/Activity%20Search.png?token=ADIPES6Q7RACGKB7N6JK3K27TQTJK) | ![3PTS Contest Summary](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/contests/Summary%20After%20Contest.png?token=ADIPESZXDPCVZZMG6B5J5MK7TQTKE) | ![Match Summary](https://raw.githubusercontent.com/kachmashk/BasketProtocol/develop/screenshots/matches/Summary%20After%20Match.png?token=ADIPES6JSESCDFKNV4EJR427TQTKK)

# ToDo
## v0.9.5:
  1. General:
      - [x] sign in with email & password
      - [x] sign in with google
      - [x] sign in anonymously
      - [x] change account's name
      - [x] change account's email
      - [x] light theme
      - [x] dark theme
      - [x] amoled theme
  2. Matches:
      - [x] with selected minutes per quarter
      - [x] with selected points per quarter
      - [x] with selected points (one quarter game)
      - [x] overtime (minutes match)
      - [x] overtime (points match)
      - [x] overtime (one quarter game)
      - [x] search finished matches
      - [x] delete matches
      - [x] quit match & finish later
  3. 3PTS Contests:
      - [x] with selected amount of shots per zone
      - [x] overtime with half of shots per zone
      - [x] overtime goes on until someone wins
      - [x] search finished contests
      - [x] delete contests
      - [x] quit contest & finish later
### v0.9.6:
   1. General:
      - [ ] verify that contest cannot be played with 1 or less players
      - [ ] do not allow email change while not signed with email & password
   2. Testing:
      - [ ] unit tests
      - [ ] integration test
### v0.9.7: 
   1. Matches:
      - [ ] save created teams
      - [ ] defensive & offensive rebounds seperated
      - [ ] fouls
      - [ ] free throws
      - [ ] substitutions
   1. General:
      - [ ] players collection in database(?)
      - [ ] localizations
### v0.9.8:
   1. 3PTS Contest Tournaments:
      - [ ] divide players for groups
      - [ ] let user decide how many players from each group will qualify to finals
### v0.9.9:
   1. Match Tournaments:
      - [ ] put players into X baskets where X = teams amount to random squads
      - [ ] play with predefined teams
      - [ ] set one match setting within all the matches during the tournament
      - [ ] league setting
        - [ ] number of plays against each team
      - [ ] knockout setting
        - [ ] number of plays against each team
        - [ ] number of matches in the final
      - [ ] league + knockout setting
        - [ ] number of plays against each team during league
        - [ ] number of plays against each team during knockout
        - [ ] number of matches in the final
### v1.0.0:
   1. General:
      - [ ] redefine user experience & user interface
