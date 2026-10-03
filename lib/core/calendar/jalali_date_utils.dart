import 'package:shamsi_date/shamsi_date.dart';

import 'jalali_birth_date.dart';

class JalaliDateUtils {
  const JalaliDateUtils._();

  static Jalali today() => Jalali.fromDateTime(DateTime.now());

  static Jalali addDays(Jalali date, int days) {
    if (days == 0) {
      return date;
    }

    var year = date.year;
    var month = date.month;
    var day = date.day;

    if (days > 0) {
      for (var i = 0; i < days; i++) {
        final monthLength = Jalali(year, month, 1).monthLength;

        if (day < monthLength) {
          day++;
        } else {
          day = 1;

          if (month < 12) {
            month++;
          } else {
            month = 1;
            year++;
          }
        }
      }
    } else {
      for (var i = 0; i < -days; i++) {
        if (day > 1) {
          day--;
        } else {
          if (month > 1) {
            month--;
          } else {
            month = 12;
            year--;
          }

          day = Jalali(year, month, 1).monthLength;
        }
      }
    }

    return Jalali(year, month, day);
  }

  static Jalali addWeeks(Jalali date, int weeks) {
    return addDays(date, weeks * 7);
  }

  static Jalali addMonths(Jalali date, int months) {
    final total = date.year * 12 + (date.month - 1) + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;

    final monthLength = Jalali(year, month, 1).monthLength;
    final day = date.day > monthLength ? monthLength : date.day;

    return Jalali(year, month, day);
  }

  static Jalali addYears(Jalali date, int years) {
    return addMonths(date, years * 12);
  }

  static JalaliBirthDate birthDateFrom(Jalali date) {
    return JalaliBirthDate.fromJalali(date);
  }

  static String format(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
