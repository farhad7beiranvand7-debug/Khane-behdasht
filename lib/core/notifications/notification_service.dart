import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../calendar/jalali_birth_date.dart';
import '../scheduling/care_item.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> reschedule(List<ScheduleItem> items, String personName) async {
    await initialize();
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    for (final item in items) {
      if (item.isCompleted) continue;
      final scheduled = _reminderDate(item.dueDate, now);
      if (scheduled == null || !scheduled.isAfter(now)) continue;

      final id = item.id.hashCode & 0x7fffffff;
      await _plugin.zonedSchedule(
        id,
        'یادآوری سلامت',
        '$personName: ${item.title}',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'health_reminders',
            'یادآوری‌های سلامت',
            channelDescription: 'یادآوری مراقبت‌ها و واکسیناسیون',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: item.id,
      );
    }
  }

  tz.TZDateTime? _reminderDate(JalaliBirthDate dueDate, tz.TZDateTime now) {
    final due = dueDate.toDateTime();
    var date = tz.TZDateTime(
      tz.local,
      due.year,
      due.month,
      due.day,
      9,
    );
    if (!date.isAfter(now)) {
      date = tz.TZDateTime(
        tz.local,
        due.year,
        due.month,
        due.day,
        9,
      );
    }
    return date;
  }
}
