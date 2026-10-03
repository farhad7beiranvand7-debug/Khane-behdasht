import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/calendar/jalali_birth_date.dart';
import '../domain/models/person.dart';

class FamilyMemberStore {
  const FamilyMemberStore({this.fileForTesting});

  final File? fileForTesting;

  Future<File> _file() async {
    if (fileForTesting != null) return fileForTesting!;
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/family_members.json');
  }

  Future<List<Person>> load() async {
    final file = await _file();
    if (!await file.exists()) return [];
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) return [];
    final decoded = jsonDecode(contents);
    if (decoded is! List) return [];

    return decoded.map<Person>((raw) {
      final json = Map<String, dynamic>.from(raw as Map);
      final conditionNames = (json['conditions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toSet();
      final conditions = conditionNames
          .map(_conditionFromString)
          .whereType<HealthCondition>()
          .toSet();
      if (conditions.isEmpty) conditions.add(HealthCondition.none);

      final lmp = json['lmpDate'] as Map<String, dynamic>?;
      return Person(
        id: json['id'] as String,
        firstName: (json['firstName'] ?? json['name'] ?? '') as String,
        lastName: (json['lastName'] ?? '') as String,
        birthDate: JalaliBirthDate(
          year: json['birthYear'] as int,
          month: json['birthMonth'] as int,
          day: json['birthDay'] as int,
        ),
        sex: _sexFromString((json['gender'] ?? 'male').toString()),
        conditions: conditions,
        isPregnant: json['isPregnant'] as bool? ?? false,
        lmpDate: lmp == null
            ? null
            : JalaliBirthDate(
                year: lmp['year'] as int,
                month: lmp['month'] as int,
                day: lmp['day'] as int,
              ),
      );
    }).toList();
  }

  Future<void> save(List<Person> members) async {
    final file = await _file();
    final contents = jsonEncode(members.map(_toJson).toList());
    await file.writeAsString(contents, flush: true);
  }

  Map<String, dynamic> _toJson(Person member) => {
        'id': member.id,
        'firstName': member.firstName,
        'lastName': member.lastName,
        'birthYear': member.birthDate.year,
        'birthMonth': member.birthDate.month,
        'birthDay': member.birthDate.day,
        'gender': member.sex.name,
        'conditions': member.conditions.map((e) => e.name).toList(),
        'isPregnant': member.isPregnant,
        if (member.lmpDate != null)
          'lmpDate': {
            'year': member.lmpDate!.year,
            'month': member.lmpDate!.month,
            'day': member.lmpDate!.day,
          },
      };

  PersonSex _sexFromString(String value) => PersonSex.values.firstWhere(
        (sex) => sex.name == value,
        orElse: () => PersonSex.male,
      );

  HealthCondition? _conditionFromString(String value) {
    for (final condition in HealthCondition.values) {
      if (condition.name == value) return condition;
    }
    return null;
  }
}
