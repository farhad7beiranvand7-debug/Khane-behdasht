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
