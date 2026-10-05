import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/main.dart';

void main() {
  testWidgets(
    'home page renders successfully',
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
        find.byType(HomePage),
        findsOneWidget,
      );

      expect(
        find.byType(Scaffold),
        findsOneWidget,
      );
    },
  );
}
