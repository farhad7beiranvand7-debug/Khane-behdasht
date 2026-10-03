import 'package:shamsi_date/shamsi_date.dart';

import 'jalali_birth_date.dart';

class JalaliDateUtils {
  const JalaliDateUtils._();

  static Jalali today() => Jalali.fromDateTime(DateTime.now());

  static Jalali addDays(Jalali date, int days) {
    var result = date;
    if (days >= 0) {
      for (var i = 0; i < days; i++) {
        result = _nextDay(result);
      }
    } else {
      for (var i = 0; i < -days; i++) {
        result = _previousDay(result);
      }
    }
    return result;
  }

  static Jalali addWeeks(Jalali date, int weeks) =>
      addDays(date, weeks * 7);

  static Jalali addMonths(Jalali date, int months) {
    final total = date.year * 12 + (date.month - 1) + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;

    final monthLength = Jalali(year, month, 1).monthLength;
    final day = date.day > monthLength ? monthLength : date.day;

    return Jalali(year, month, day);
  }

  static Jalali addYears(Jalali date, int years) =>
      addMonths(date, years * 12);

  static JalaliBirthDate birthDateFrom(Jalali date) =>
      JalaliBirthDate.fromJalali(date);

  static String format(Jalali date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  static Jalali _nextDay(Jalali date) {
    if (date.day < date.monthLength) {
      return Jalali(date.year, date.month, date.day + 1);
    }

    if (date.month < 12) {
      return Jalali(date.year, date.month + 1, 1);
    }

    return Jalali(date.year + 1, 1, 1);
  }

  static Jalali _previousDay(Jalali date) {
    if (date.day > 1) {
      return Jalali(date.year, date.month, date.day - 1);
    }

    if (date.month > 1) {
      final previousMonth = Jalali(date.year, date.month - 1, 1);
      return Jalali(
        date.year,
        date.month - 1,
        previousMonth.monthLength,
      );
    }

    final previousYearMonth = Jalali(date.year - 1, 12, 1);

    return Jalali(
      date.year - 1,
      12,
      previousYearMonth.monthLength,
    );
  }
}
