import 'package:flutter_test/flutter_test.dart';
import 'package:basket_protocol/core/validators/input_validation.dart';

void main() {
  group('whitespace & empty input for all validators ->', () {
    test('whitespace -> should return \'cannot be empty!\' error', () {
      const _input = '    ';

      expect(InputValidation.email(_input), matches('cannot be empty'));
      expect(InputValidation.password(_input), matches('cannot be empty'));
      expect(InputValidation.passwordConfirmation(_input, _input),
          matches('cannot be empty'));
      expect(InputValidation.allowOnlyLettersAndSpaces(_input),
          matches('cannot be empty'));
      expect(
          InputValidation.allowNumbersOnly(_input), matches('cannot be empty'));
    });

    test('empty -> should return \'cannot be empty!\' error', () {
      const _input = '';

      expect(InputValidation.email(_input), matches('cannot be empty'));
      expect(InputValidation.password(_input), matches('cannot be empty'));
      expect(InputValidation.passwordConfirmation(_input, _input),
          matches('cannot be empty'));
      expect(InputValidation.allowOnlyLettersAndSpaces(_input),
          matches('cannot be empty'));
      expect(
          InputValidation.allowNumbersOnly(_input), matches('cannot be empty'));
    });
  });

  group('email validation ->', () {
    test('should pass correct email', () {
      const _input = 'test@mail.com';
      expect(InputValidation.email(_input), isNull);
    });

    test('should return \'wrong email format!\' error', () {
      const _input = 'asdqwe';
      expect(InputValidation.email(_input), matches('wrong email format'));
    });
  });

  group('password validation ->', () {
    test('should pass correct password', () {
      const _input = 'asdqwe231asdq';
      expect(InputValidation.password(_input), isNull);
    });

    test('should return \'password must be at least 8 characters!\' error', () {
      const _input = 'asdqwe';
      expect(InputValidation.password(_input),
          matches('password must be at least 8 characters'));
    });
  });

  group('confirm password validation ->', () {
    test('should pass correct password confirmation', () {
      const _originInput = '123123123';
      const _confirmationInput = '123123123';

      final _passwordConfirmationResult = InputValidation.passwordConfirmation(
          _confirmationInput, _originInput);

      expect(_passwordConfirmationResult, isNull);
    });

    test('should return \'passwords are not the same!\' error', () {
      const _originInput = '123123123';
      const _confirmationInput = '321321321';

      final _result = InputValidation.passwordConfirmation(
          _confirmationInput, _originInput);

      expect(_result, matches('passwords are not the same'));
    });
  });

  group('allow only letters and whitespace validation ->', () {
    test('should pass correct letters & spaces input', () {
      const _input = 'asxcXAF Sqsad';
      expect(InputValidation.allowOnlyLettersAndSpaces(_input), isNull);
    });

    test('should return \'should contain only letters and spaces!\' error', () {
      const _input = 'asxc.XAF Sqs2ad5';
      expect(InputValidation.allowOnlyLettersAndSpaces(_input),
          matches('should contain only letters and spaces'));
    });
  });

  group('numbers only validation ->', () {
    test('should pass correct input', () {
      const _input = '32';
      expect(InputValidation.allowNumbersOnly(_input), isNull);
    });

    test('should return \'should contain only numbers!\' error', () {
      const _input = '2 ';
      expect(InputValidation.allowNumbersOnly(_input),
          matches('should contain only numbers'));
    });
  });
}
