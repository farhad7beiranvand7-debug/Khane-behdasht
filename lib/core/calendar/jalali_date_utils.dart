import 'package:shamsi_date/shamsi_date.dart';

import 'jalali_birth_date.dart';

class JalaliDateUtils {
  const JalaliDateUtils._();

  static Jalali today() => Jalali.now();

  // محاسبه مستقیم در تقویم جلالی؛
  // از تبدیل رفت و برگشت Jalali -> DateTime -> Jalali استفاده نمی‌کنیم.
  static Jalali addDays(Jalali date, int days) => date.addDays(days);

  static Jalali addWeeks(Jalali date, int weeks) =>
      date.addDays(weeks * 7);

  static Jalali addMonths(Jalali date, int months) =>
      date.addMonths(months);

  static Jalali addYears(Jalali date, int years) =>
      date.addYears(years);

  static JalaliBirthDate birthDateFrom(Jalali date) =>
      JalaliBirthDate.fromJalali(date);

  static String format(Jalali date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

این تغییر مهم است، چون قبلاً این کار انجام می‌شد:

Jalali -> DateTime -> add(Duration) -> Jalali

ولی حالا مستقیماً:

Jalali -> addDays()

انجام می‌شود. "shamsi_date" رسماً "addDays" و "addMonths" و "addYears" را برای خود "Jalali" ارائه می‌کند.

---

مرحله ۲ — تست "widget_test.dart"

فایل:

"test/widget_test.dart"

را کامل با این نسخه جایگزین کن:

:::writing{variant="document" id="73164" title="widget_test.dart"}

import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home page shows family entry point', (tester) async {
    await tester.pumpWidget(const KhaneBehdashtApp());

    // اجازه می‌دهیم بارگذاری اطلاعات خانواده از storage آزمایشی کامل شود.
    await tester.pumpAndSettle();

    expect(find.text('خانه بهداشت پزشک خانواده'), findsOneWidget);
    expect(find.text('اعضای خانواده'), findsOneWidget);
    expect(find.text('افزودن عضو'), findsOneWidget);
  });
}

اینجا "pumpAndSettle()" را حذف نکردیم؛ بنابراین تست همچنان بررسی می‌کند که صفحه واقعاً پس از بارگذاری کامل نمایش داده شود. فقط storage واقعی دستگاه را با storage آزمایشی جایگزین کردیم.

مرحله ۳ — "main.dart"

فعلاً هیچ تغییری در "main.dart" نده.

کدی که فرستادی برای این خطای خاص مشکلی ندارد، چون تست مستقیماً:

KhaneBehdashtApp()

را اجرا می‌کند و اصلاً تابع "main()" را صدا نمی‌زند.

---

مرحله ۴ — حالا فقط این را اجرا کن

در GitHub Actions دوباره:

Flutter tests

را اجرا کن.

هدف ما این است که:

schedule_engine_test.dart
PASS
widget_test.dart
PASS

و بعد:

flutter test

بدون خطا تمام شود.

فعلاً "schedule_engine.dart" را دست نزن. اگر بعد از این دو اصلاح هنوز خطایی باقی ماند، متن دقیق خطای جدید را بفرست؛ مرحله بعدی را بر اساس همان خطا اصلاح می‌کنیم، نه با تغییر تصادفی کد.
