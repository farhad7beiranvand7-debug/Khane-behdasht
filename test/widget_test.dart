import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/main.dart';

void main() {
  testWidgets('home page shows family entry point', (tester) async {
    await tester.pumpWidget(const KhaneBehdashtApp());

    await tester.pump();

    expect(find.text('خانه بهداشت پزشک خانواده'), findsOneWidget);
    expect(find.text('اعضای خانواده'), findsOneWidget);
    expect(find.text('افزودن عضو'), findsOneWidget);
  });
}
