import 'package:shamsi_date/shamsi_date.dart';

import 'jalali_birth_date.dart';

class JalaliAge {
  const JalaliAge({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;

  @override
  String toString() => '$years سال، $months ماه، $days روز';
}

class AgeCalculator {
  const AgeCalculator();

  JalaliAge calculate({
    required JalaliBirthDate birthDate,
    Jalali? asOf,
  }) {
    final reference = asOf ?? Jalali.fromDateTime(DateTime.now());
    final birth = birthDate.toJalali();
    if (reference.toDateTime().isBefore(birth.toDateTime())) {
      throw ArgumentError('تاریخ تولد نمی‌تواند بعد از تاریخ مرجع باشد.');
    }

    var years = reference.year - birth.year;
    final anniversaryDay = _safeDay(reference.year, birth.month, birth.day);
    final currentYearAnniversary = Jalali(reference.year, birth.month, anniversaryDay);
    if (reference.toDateTime().isBefore(currentYearAnniversary.toDateTime())) {
      years--;
    }

    final anniversaryYear = birth.year + years;
    final lastAnniversary = Jalali(
      anniversaryYear,
      birth.month,
      _safeDay(anniversaryYear, birth.month, birth.day),
    );

    var months = (reference.year - lastAnniversary.year) * 12 +
        reference.month - lastAnniversary.month;
    var monthAnchor = _addMonths(lastAnniversary, months);
    if (monthAnchor.toDateTime().isAfter(reference.toDateTime())) {
      months--;
      monthAnchor = _addMonths(lastAnniversary, months);
    }

    final days = reference
        .toDateTime()
        .difference(monthAnchor.toDateTime())
        .inDays;

    return JalaliAge(years: years, months: months, days: days);
  }

  int _safeDay(int year, int month, int day) {
    final length = Jalali(year, month, 1).monthLength;
    return day > length ? length : day;
  }

  Jalali _addMonths(Jalali date, int months) {
    final total = date.year * 12 + date.month - 1 + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    return Jalali(year, month, _safeDay(year, month, date.day));
  }
}
