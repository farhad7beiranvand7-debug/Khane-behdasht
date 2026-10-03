import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:khane_behdasht/core/calendar/jalali_birth_date.dart';
import 'package:khane_behdasht/core/calendar/jalali_date_utils.dart';
import 'package:khane_behdasht/core/scheduling/care_item.dart';
import 'package:khane_behdasht/core/scheduling/schedule_engine.dart';
import 'package:khane_behdasht/domain/models/person.dart';

void main() {
  const engine = ScheduleEngine();

  test('uses exact Jalali birth date for vaccination due dates', () {
    final person = Person(
      id: 'child',
      firstName: 'علی',
      lastName: 'رضایی',
      birthDate: JalaliBirthDate(
        year: 1404,
        month: 7,
        day: 15,
      ),
      sex: PersonSex.male,
    );

    final items = engine.build(
      person,
      asOf: Jalali(1404, 7, 20),
    );

    final twoMonth = items.firstWhere(
      (item) => item.id.endsWith('pentavalent-2'),
    );

    expect(
      twoMonth.dueDate.toString(),
      '1404/09/15',
    );

    expect(
      twoMonth.category,
      ScheduleCategory.vaccination,
    );
  });

  test('adds diabetes follow-up reminders', () {
    final person = Person(
      id: 'adult',
      firstName: 'رضا',
      lastName: 'احمدی',
      birthDate: JalaliBirthDate(
        year: 1370,
        month: 1,
        day: 1,
      ),
      sex: PersonSex.male,
      conditions: const {
        HealthCondition.diabetes,
      },
    );

    final items = engine.build(
      person,
      asOf: Jalali(1405, 7, 1),
    );

    expect(
      items.any(
        (item) => item.title == 'پیگیری دیابت',
      ),
      isTrue,
    );
  });

  test('creates pregnancy reminders from LMP', () {
    final person = Person(
      id: 'mother',
      firstName: 'مریم',
      lastName: 'احمدی',
      birthDate: JalaliBirthDate(
        year: 1375,
        month: 1,
        day: 1,
      ),
      sex: PersonSex.female,
      isPregnant: true,
      lmpDate: JalaliBirthDate(
        year: 1405,
        month: 6,
        day: 1,
      ),
    );

    final items = engine.build(
      person,
      asOf: Jalali(1405, 7, 1),
    );

    final pregnancy = items
        .where(
          (item) => item.category == ScheduleCategory.pregnancy,
        )
        .toList();

    expect(
      pregnancy,
      hasLength(8),
    );

    expect(
      pregnancy.first.dueDate.toString(),
      '1405/07/13',
    );
  });

  test('Jalali adds exactly 42 days', () {
    final result = JalaliDateUtils.addDays(
      Jalali(1405, 6, 1),
      42,
    );

    expect(
      result.toString(),
      '1405/07/13',
    );
  });

  test('Jalali adds one week correctly', () {
    final result = JalaliDateUtils.addWeeks(
      Jalali(1405, 6, 1),
      1,
    );

    expect(
      result.toString(),
      '1405/06/08',
    );
  });

  test('Jalali adds one month while preserving the day', () {
    final result = JalaliDateUtils.addMonths(
      Jalali(1405, 6, 15),
      1,
    );

    expect(
      result.toString(),
      '1405/07/15',
    );
  });

  test('Jalali adds twelve months correctly', () {
    final result = JalaliDateUtils.addMonths(
      Jalali(1404, 7, 15),
      12,
    );

    expect(
      result.toString(),
      '1405/07/15',
    );
  });
}
