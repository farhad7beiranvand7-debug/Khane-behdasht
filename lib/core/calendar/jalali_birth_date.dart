import 'package:shamsi_date/shamsi_date.dart';

class JalaliBirthDate implements Comparable<JalaliBirthDate> {
  JalaliBirthDate({
    required this.year,
    required this.month,
    required this.day,
  }) {
    if (year < 1 || month < 1 || month > 12 || day < 1) {
      throw ArgumentError('تاریخ شمسی نامعتبر است.');
    }

    final normalized = Jalali(year, month, day);

    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('تاریخ شمسی نامعتبر است.');
    }
  }

  final int year;
  final int month;
  final int day;

  Jalali toJalali() => Jalali(year, month, day);

  DateTime toDateTime() => toJalali().toDateTime();

  static JalaliBirthDate fromJalali(Jalali date) {
    return JalaliBirthDate(
      year: date.year,
      month: date.month,
      day: date.day,
    );
  }

  static JalaliBirthDate fromDateTime(DateTime date) {
    return fromJalali(
      Jalali.fromDateTime(date),
    );
  }

  /// سن دقیق فرد تا امروز به صورت سال، ماه و روز.
  String exactAge() {
    final birth = toJalali();
    final today = Jalali.now();

    if (birth > today) {
      return 'هنوز متولد نشده';
    }

    var years = today.year - birth.year;
    var months = today.month - birth.month;

    if (today.day < birth.day) {
      months--;

      if (months < 0) {
        months += 12;
        years--;
      }
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    final anniversary = birth
        .addYears(years)
        .addMonths(months);

    var days = today
        .toDateTime()
        .difference(anniversary.toDateTime())
        .inDays;

    if (days < 0) {
      months--;

      if (months < 0) {
        months = 11;
        years--;
      }

      final correctedAnniversary = birth
          .addYears(years)
          .addMonths(months);

      days = today
          .toDateTime()
          .difference(correctedAnniversary.toDateTime())
          .inDays;
    }

    final parts = <String>[];

    if (years > 0) {
      parts.add(
        '${_persianNumber(years)} سال',
      );
    }

    if (months > 0) {
      parts.add(
        '${_persianNumber(months)} ماه',
      );
    }

    if (days > 0 || parts.isEmpty) {
      parts.add(
        '${_persianNumber(days)} روز',
      );
    }

    return parts.join(' و ');
  }

  String _persianNumber(int number) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';

    return number
        .toString()
        .split('')
        .map(
          (character) {
            final index = english.indexOf(character);
            return index >= 0
                ? persian[index]
                : character;
          },
        )
        .join();
  }

  @override
  int compareTo(JalaliBirthDate other) {
    return toDateTime().compareTo(
      other.toDateTime(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JalaliBirthDate &&
        year == other.year &&
        month == other.month &&
        day == other.day;
  }

  @override
  int get hashCode {
    return Object.hash(
      year,
      month,
      day,
    );
  }

  @override
  String toString() {
    return '$year/'
        '${month.toString().padLeft(2, '0')}/'
        '${day.toString().padLeft(2, '0')}';
  }
}
