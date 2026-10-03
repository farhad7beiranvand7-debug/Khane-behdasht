import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:khane_behdasht/core/calendar/age_calculator.dart';
import 'package:khane_behdasht/core/calendar/jalali_birth_date.dart';

void main() {
  const calculator = AgeCalculator();

  test('accepts valid Jalali date', () {
    expect(
      JalaliBirthDate(year: 1400, month: 7, day: 9).toString(),
      '1400/07/09',
    );
  });

  test('rejects invalid Jalali date', () {
    expect(() => JalaliBirthDate(year: 1400, month: 13, day: 1), throwsArgumentError);
    expect(() => JalaliBirthDate(year: 1400, month: 7, day: 0), throwsArgumentError);
  });

  test('calculates exact age on birthday', () {
    final age = calculator.calculate(
      birthDate: JalaliBirthDate(year: 1400, month: 7, day: 9),
      asOf: Jalali(1405, 7, 9),
    );
    expect(age.years, 5);
    expect(age.months, 0);
    expect(age.days, 0);
  });

  test('does not count the next birthday early', () {
    final age = calculator.calculate(
      birthDate: JalaliBirthDate(year: 1400, month: 7, day: 9),
      asOf: Jalali(1405, 7, 8),
    );
    expect(age.years, 4);
    expect(age.months, 11);
    expect(age.days, 30);
  });

  test('rejects a future birth date', () {
    expect(
      () => calculator.calculate(
        birthDate: JalaliBirthDate(year: 1405, month: 7, day: 10),
        asOf: Jalali(1405, 7, 9),
      ),
      throwsArgumentError,
    );
  });
}
