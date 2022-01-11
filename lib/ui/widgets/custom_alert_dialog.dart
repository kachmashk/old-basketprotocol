import 'package:flutter/material.dart';

import 'package:basket_protocol/ui/widgets/custom_button.dart';

Future buildCustomAlertDialog(BuildContext context, String _title,
    [Widget _proceedButton]) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        key: Key('customAlertDialog'),
        title: Text(_title),
        actions: <Widget>[
          _proceedButton,
          CustomButton(
            key: Key('dismissButton'),
            label: 'dismiss',
            isFlatButtonWanted: true,
            onClick: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
