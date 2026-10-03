import '../../core/calendar/jalali_birth_date.dart';

enum PersonSex { female, male }

enum HealthCondition {
  none,
  hypertension,
  diabetes,
}

class Person {
  const Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.sex,
    this.conditions = const {HealthCondition.none},
    this.isPregnant = false,
    this.lmpDate,
  });

  final String id;
  final String firstName;
  final String lastName;
  final JalaliBirthDate birthDate;
  final PersonSex sex;
  final Set<HealthCondition> conditions;
  final bool isPregnant;
  final JalaliBirthDate? lmpDate;

  String get fullName => '$firstName $lastName'.trim();

  Person copyWith({
    String? id,
    String? firstName,
    String? lastName,
    JalaliBirthDate? birthDate,
    PersonSex? sex,
    Set<HealthCondition>? conditions,
    bool? isPregnant,
    JalaliBirthDate? lmpDate,
    bool clearLmpDate = false,
  }) {
    return Person(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      conditions: conditions ?? this.conditions,
      isPregnant: isPregnant ?? this.isPregnant,
      lmpDate: clearLmpDate ? null : (lmpDate ?? this.lmpDate),
    );
  }
}
