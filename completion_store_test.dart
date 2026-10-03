import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/core/calendar/jalali_birth_date.dart';
import 'package:khane_behdasht/data/completion_store.dart';

void main() {
  test('persists completion dates in Jalali format', () async {
    final dir = await Directory.systemTemp.createTemp('completion_store_');
    try {
      final store = CompletionStore(fileForTesting: File('${dir.path}/done.json'));
      final date = JalaliBirthDate(year: 1405, month: 7, day: 10);
      await store.setCompleted('item-1', date);
      final loaded = await store.load();
      expect(loaded['item-1']?.toString(), '1405/07/10');
      await store.clear('item-1');
      expect((await store.load())['item-1'], isNull);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
