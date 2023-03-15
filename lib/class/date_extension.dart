import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime applied(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  String onlyDate({String format = 'dd-MM-yyyy', String locale = 'ES'}) {
    return DateFormat(format, locale).format(this);
  }

  String onlyTime({String format = 'kk:mm'}) {
    return DateFormat(format).format(this);
  }

  DateTime resetTime() {
    return DateTime(year, month, day, 0, 0);
  }

  DateTime firstDateAndResetTime() {
    return DateTime(year, month, 1, 0, 0);
  }
}
