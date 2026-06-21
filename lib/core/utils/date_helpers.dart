import 'package:intl/intl.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';

class DateHelpers {
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('yyyy оны MMMM d');
  static final _timeFormat = DateFormat('HH:mm');

  static String toApiDate(DateTime date) => _dateFormat.format(date);

  static String todayApiDate() => AppTimezone.todayDateStr();

  static String displayDate(DateTime date) => _displayFormat.format(date);

  static String displayTime(DateTime date) => _timeFormat.format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
