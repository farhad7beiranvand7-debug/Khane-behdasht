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

بعد فقط Commit changes بزن و Workflow را اجرا کن.

این بار انتظار داریم:

- "flutter analyze" ✅
- هر ۱۵ تست یا بیشتر ✅
- سپس "Build Release APK" اجرا شود
- سپس "Build Release AAB" اجرا شود

هیچ فایل دیگری را فعلاً تغییر نده.
