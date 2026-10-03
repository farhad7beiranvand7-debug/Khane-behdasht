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

  static JalaliBirthDate fromJalali(Jalali date) => JalaliBirthDate(
        year: date.year,
        month: date.month,
        day: date.day,
      );

  static JalaliBirthDate fromDateTime(DateTime date) => fromJalali(
        Jalali.fromDateTime(date),
      );

  @override
  int compareTo(JalaliBirthDate other) => toDateTime().compareTo(other.toDateTime());

  @override
  bool operator ==(Object other) =>
      other is JalaliBirthDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
}
