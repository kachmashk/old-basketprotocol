import 'package:flutter/material.dart';

import 'package:basket_protocol/core/db/match_db.dart';
import 'package:basket_protocol/core/db/contest_db.dart';
import 'package:basket_protocol/ui/widgets/custom_button.dart';
import 'package:basket_protocol/ui/widgets/custom_alert_dialog.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';

Future buildDeleteActivityDialog(BuildContext context, String _collection,
    String _userId, String _activityId) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'leaving will delete this data, are you sure you want to quit?',
        ),
        actions: <Widget>[
          CustomButton(
            key: Key('confirmButton'),
            onClick: () => _deleteRecordAndNavigateHome(
                context, _collection, _userId, _activityId),
            label: 'yes',
            isFlatButtonWanted: true,
          ),
          CustomButton(
            key: Key('cancelButton'),
            onClick: () => Navigator.pop(context),
            label: 'no',
            isFlatButtonWanted: true,
          ),
        ],
      );
    },
  );
}

Future<void> _deleteRecordAndNavigateHome(BuildContext context,
    String _collection, String _userId, String _activityId) async {
  try {
    switch (_collection) {
      case 'contests':
        ContestDB.deleteContestDocument(_userId, _activityId);
        break;

      case 'matches':
        MatchDB.deleteMatchDocument(_userId, _activityId);
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MatchSetupPage(),
      ),
      (route) => false,
    );
  } catch (error) {
    buildCustomAlertDialog(context, error.toString());
    rethrow;
  }
}
