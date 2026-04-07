import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String toDisplayDate(String locale) {
    return DateFormat.yMMMd(locale).format(this);
  }

  String toDisplayTime(String locale) {
    return DateFormat.jm(locale).format(this);
  }

  String toDisplayDateTime(String locale) {
    return DateFormat.yMMMd(locale).add_jm().format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
