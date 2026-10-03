import 'package:shamsi_date/shamsi_date.dart';

import 'jalali_birth_date.dart';

class JalaliDateUtils {
  const JalaliDateUtils._();

  static Jalali today() => Jalali.fromDateTime(DateTime.now());

  static Jalali addDays(Jalali date, int days) =>
      Jalali.fromDateTime(date.toDateTime().add(Duration(days: days)));

  static Jalali addWeeks(Jalali date, int weeks) => addDays(date, weeks * 7);

  static Jalali addMonths(Jalali date, int months) {
    final total = date.year * 12 + (date.month - 1) + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    final day = date.day > Jalali(year, month, 1).monthLength
        ? Jalali(year, month, 1).monthLength
        : date.day;
    return Jalali(year, month, day);
  }

  static Jalali addYears(Jalali date, int years) =>
      addMonths(date, years * 12);

  static JalaliBirthDate birthDateFrom(Jalali date) =>
      JalaliBirthDate.fromJalali(date);

  static String format(Jalali date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}
