import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/calendar/jalali_birth_date.dart';

class CompletionStore {
  const CompletionStore({this.fileForTesting});

  final File? fileForTesting;

  Future<File> _file() async {
    if (fileForTesting != null) return fileForTesting!;
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/completed_schedule.json');
  }

  Future<Map<String, JalaliBirthDate>> load() async {
    final file = await _file();
    if (!await file.exists()) return {};
    final raw = jsonDecode(await file.readAsString());
    if (raw is! Map) return {};
    final result = <String, JalaliBirthDate>{};
    raw.forEach((key, value) {
      if (value is Map) {
        result[key.toString()] = JalaliBirthDate(
          year: value['year'] as int,
          month: value['month'] as int,
          day: value['day'] as int,
        );
      }
    });
    return result;
  }

  Future<void> setCompleted(String id, JalaliBirthDate date) async {
    final map = await load();
    map[id] = date;
    await _save(map);
  }

  Future<void> clear(String id) async {
    final map = await load();
    map.remove(id);
    await _save(map);
  }

  Future<void> _save(Map<String, JalaliBirthDate> map) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode({
        for (final entry in map.entries)
          entry.key: {
            'year': entry.value.year,
            'month': entry.value.month,
            'day': entry.value.day,
          },
      }),
      flush: true,
    );
  }
}
