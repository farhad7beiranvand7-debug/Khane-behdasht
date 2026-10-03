import 'package:shamsi_date/shamsi_date.dart';

import 'jalali_birth_date.dart';

class JalaliDateUtils {
  const JalaliDateUtils._();

  /// تاریخ شمسی امروز
  static Jalali today() {
    return Jalali.now();
  }

  /// اضافه کردن تعداد روز مشخص به تاریخ شمسی
  ///
  /// از موتور داخلی shamsi_date استفاده می‌شود تا
  /// محاسبات ماه‌ها، سال‌ها و سال کبیسه کاملاً شمسی باشند.
  static Jalali addDays(Jalali date, int days) {
    return date.addDays(days);
  }

  /// اضافه کردن تعداد هفته مشخص به تاریخ شمسی
  static Jalali addWeeks(Jalali date, int weeks) {
    return date.addDays(weeks * 7);
  }

  /// اضافه کردن ماه به تاریخ شمسی
  ///
  /// مثال:
  /// 1405/06/15 + 1 ماه = 1405/07/15
  static Jalali addMonths(Jalali date, int months) {
    return date.addMonths(months);
  }

  /// اضافه کردن سال به تاریخ شمسی
  static Jalali addYears(Jalali date, int years) {
    return date.addYears(years);
  }

  /// تبدیل Jalali به مدل تاریخ تولد برنامه
  static JalaliBirthDate birthDateFrom(Jalali date) {
    return JalaliBirthDate.fromJalali(date);
  }

  /// قالب استاندارد تاریخ برای نمایش در برنامه
  ///
  /// خروجی:
  /// 1405/07/13
  static String format(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
