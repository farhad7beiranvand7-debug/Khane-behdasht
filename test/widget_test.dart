import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/main.dart';

void main() {
  testWidgets(
    'diagnostic app starts successfully',
    (tester) async {
      await tester.pumpWidget(
        const DiagnosticApp(),
      );

      await tester.pump();

      expect(
        find.text('خانه بهداشت پزشک خانواده'),
        findsWidgets,
      );

      expect(
        find.text('برنامه با موفقیت اجرا شد.'),
        findsOneWidget,
      );
    },
  );
}
