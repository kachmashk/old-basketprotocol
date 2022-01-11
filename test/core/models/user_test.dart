import 'package:flutter_test/flutter_test.dart';
import 'package:basket_protocol/core/models/user.dart';

void main() {
  group('user model', () {
    test('verify created basic user', () {
      final _user = User(
        id: 'hGGprEZgrfZYGAdEMazq7QIpi9o1',
        email: 'test@mail.com',
      );

      expect(_user.id, matches('hGGprEZgrfZYGAdEMazq7QIpi9o1'));
      expect(_user.email, matches('test@mail.com'));
      expect(_user.name, isNull);
      expect(_user.isEmailVerified, isNull);
    });

    test('verify created user with all available fields', () {
      final _user = User(
          id: 'hGGprEZgrfZYGAdEMazq7QIpi9o1',
          email: 'test@mail.com',
          name: 'username',
          isEmailVerified: false);

      expect(_user.id, matches('hGGprEZgrfZYGAdEMazq7QIpi9o1'));
      expect(_user.email, matches('test@mail.com'));
      expect(_user.name, matches('username'));
      expect(_user.isEmailVerified, isFalse);
    });
  });
}
