import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/main.dart';

void main() {
  testWidgets(
    'home page shows family entry point',
    (tester) async {
      await tester.pumpWidget(
        KhaneBehdashtApp(
          home: HomePage(
            loadMembers: () async => [],
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('سلام'),
        findsOneWidget,
      );

      expect(
        find.text('دسترسی سریع'),
        findsOneWidget,
      );

      expect(
        find.text('افراد تحت پوشش'),
        findsOneWidget,
      );

      expect(
        find.text('افزودن عضو'),
        findsOneWidget,
      );
    },
  );
}

خیلی مهم

بعد از ذخیره، فایل باید دقیقاً ۳۳ خط یا کمتر باشد و بعد از آخرین "}" هیچ متن فارسی یا توضیحی نباشد.

خطاهای:

illegal_character
non_constant_identifier_names
missing function_parameters
missing function_body
172 issues found

همه پیامد همان خراب شدن فایل از حوالی line 50 هستند، نه ۱۷۲ خطای واقعی.

بعد Commit کن و دوباره Workflow را اجرا کن. اگر "Flutter analyze" سبز شد، دیگر فعلاً هیچ فایل دیگری را تغییر نده.
