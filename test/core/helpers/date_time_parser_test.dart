import 'package:flutter_test/flutter_test.dart';

import 'package:basket_protocol/core/helpers/date_time_parser.dart';

void main() {
  group('date time parser ->', () {
    final _dateTimeNow = DateTime.now();

    test('should return parsed dateTime now string', () {
      final _result = DateTimeParser.getDateTimeNowString();

      int _year = int.parse(_result.split('-')[0]);
      int _month = int.parse(_result.split('-')[1]);
      int _day = int.parse(_result.split('-')[2].split(' ')[0]);

      int _hour = int.parse(_result.split(' ')[1].split(':')[0]);
      int _minute = int.parse(_result.split(' ')[1].split(':')[1]);

      expect(_year, equals(_dateTimeNow.year));
      expect(_month, equals(_dateTimeNow.month));
      expect(_day, equals(_dateTimeNow.day));

      expect(_hour, equals(_dateTimeNow.hour));
      expect(_minute, equals(_dateTimeNow.minute));
    });

    test(
        'should return minutes difference string after dateTime string being passed',
        () {
      final _dateTimeQuarterEarlier =
          _dateTimeNow.subtract(const Duration(minutes: 15));

      final _result = DateTimeParser.updateActivityDuration(
          _dateTimeQuarterEarlier.toString());

      expect(_result, matches('15 minutes'));
      expect(int.parse(_result.split(' ')[0]), equals(15));
    });
  });
}
