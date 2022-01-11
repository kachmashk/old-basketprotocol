import 'package:flutter/material.dart';

import 'package:basket_protocol/ui/widgets/custom_button.dart';

abstract class BaseTest {
  int sum(int a, int b);
}

class Test implements BaseTest {
  int sum(int a, int b) => a + b;
}

class DevelopmentPage extends StatefulWidget {
  @override
  _DevelopmentPageState createState() => _DevelopmentPageState();
}

class _DevelopmentPageState extends State<DevelopmentPage> {
  bool _isOn = false;

  void _sum() {
    Test().sum(2, 3);
  }

  void _throwException() {
    try {
      throw Exception('custom error message');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          CustomButton(
            key: Key('sumButton'),
            label: 'sum',
            onClick: _sum,
          ),
          CustomButton(
            key: Key('exceptionButton'),
            label: 'exception',
            onClick: _throwException,
          ),
          Switch(
            key: Key('switch'),
            value: _isOn,
            onChanged: (bool value) {
              setState(() => _isOn = !_isOn);
            },
          ),
        ],
      ),
    );
  }
}
