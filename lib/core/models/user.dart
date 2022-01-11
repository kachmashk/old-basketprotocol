import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;

  User(
      {@required this.id,
      @required this.email,
      this.name,
      this.isEmailVerified});
}
