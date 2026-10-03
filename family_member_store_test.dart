import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khane_behdasht/core/calendar/jalali_birth_date.dart';
import 'package:khane_behdasht/data/family_member_store.dart';
import 'package:khane_behdasht/domain/models/person.dart';

void main() {
  late Directory directory;
  late FamilyMemberStore store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('family_store_');
    store = FamilyMemberStore(fileForTesting: File('${directory.path}/members.json'));
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('persists full family member data including pregnancy', () async {
    final person = Person(
      id: '1',
      firstName: 'مریم',
      lastName: 'رضایی',
      birthDate: JalaliBirthDate(year: 1375, month: 2, day: 12),
      sex: PersonSex.female,
      conditions: const {HealthCondition.diabetes},
      isPregnant: true,
      lmpDate: JalaliBirthDate(year: 1405, month: 6, day: 10),
    );

    await store.save([person]);
    final loaded = await store.load();

    expect(loaded.single.firstName, 'مریم');
    expect(loaded.single.lastName, 'رضایی');
    expect(loaded.single.birthDate.toString(), '1375/02/12');
    expect(loaded.single.conditions, contains(HealthCondition.diabetes));
    expect(loaded.single.isPregnant, isTrue);
    expect(loaded.single.lmpDate?.toString(), '1405/06/10');
  });
}
