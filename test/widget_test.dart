import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/main.dart';

void main() {
  testWidgets('home page shows family entry point', (tester) async {
    await tester.pumpWidget(const KhaneBehdashtApp());

    // اجازه می‌دهیم Future مربوط به بارگذاری اولیه اجرا شود.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('خانه بهداشت پزشک خانواده'), findsOneWidget);
    expect(find.text('اعضای خانواده'), findsOneWidget);
    expect(find.text('افزودن عضو'), findsOneWidget);
  });
}
