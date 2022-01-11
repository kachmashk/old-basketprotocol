class DateTimeParser {
  static String getDateTimeNowString() {
    final _dateTimeNow = DateTime.now().toString();

    return _dateTimeNow.split('.')[0].split(':')[0] +
        ':' +
        _dateTimeNow.split('.')[0].split(':')[1];
  }

  static String updateActivityDuration(String date) {
    final _date = date.split(' ')[0];
    final _time = date.split(' ')[1];

    int _year = int.parse(_date.split('-')[0]);
    int _month = int.parse(_date.split('-')[1]);
    int _day = int.parse(_date.split('-')[2]);

    int _hour = int.parse(_time.split(':')[0]);
    int _minute = int.parse(_time.split(':')[1]);

    final _beginDateTime = DateTime(_year, _month, _day, _hour, _minute);
    final _endDateTime = DateTime.now();

    return '${_endDateTime.difference(_beginDateTime).inMinutes} minutes';
  }
}
