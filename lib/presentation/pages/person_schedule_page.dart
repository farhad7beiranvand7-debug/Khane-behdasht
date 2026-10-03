import 'package:flutter/material.dart';

import '../../core/calendar/age_calculator.dart';
import '../../core/calendar/jalali_birth_date.dart';
import '../../core/calendar/jalali_date_utils.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/scheduling/care_item.dart';
import '../../core/scheduling/schedule_engine.dart';
import '../../data/completion_store.dart';
import '../../data/family_member_store.dart';
import '../../domain/models/person.dart';
import 'member_form_page.dart';

class PersonSchedulePage extends StatefulWidget {
  const PersonSchedulePage({super.key, required this.member});

  final Person member;

  @override
  State<PersonSchedulePage> createState() => _PersonSchedulePageState();
}

class _PersonSchedulePageState extends State<PersonSchedulePage> {
  final _engine = const ScheduleEngine();
  final _completionStore = const CompletionStore();
  final _memberStore = const FamilyMemberStore();
  final _ageCalculator = const AgeCalculator();

  Map<String, JalaliBirthDate> _completed = {};
  late Person _member;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _load();
  }

  Future<void> _load() async {
    final completed = await _completionStore.load();
    if (!mounted) return;

    setState(() {
      _completed = completed;
      _loading = false;
    });

    await _reschedule();
  }

  List<ScheduleItem> get _items {
    return _engine
        .build(_member)
        .map((item) {
          final completedDate = _completed[item.id];

          return completedDate == null
              ? item
              : item.copyWith(completedDate: completedDate);
        })
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<void> _reschedule() async {
    await NotificationService.instance.reschedule(
      _items,
      _member.fullName,
    );
  }

  Future<void> _toggleCompleted(ScheduleItem item) async {
    if (item.isCompleted) {
      await _completionStore.clear(item.id);
    } else {
      await _completionStore.setCompleted(
        item.id,
        JalaliDateUtils.birthDateFrom(
          JalaliDateUtils.today(),
        ),
      );
    }

    final completed = await _completionStore.load();

    if (!mounted) return;

    setState(() => _completed = completed);

    await _reschedule();
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Person>(
      MaterialPageRoute(
        builder: (_) => MemberFormPage(
          initialMember: _member,
        ),
      ),
    );

    if (updated == null || !mounted) return;

    setState(() => _member = updated);

    await _reschedule();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف فرد'),
        content: Text(
          'آیا «${_member.fullName}» حذف شود؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final members = await _memberStore.load();

    await _memberStore.save(
      members.where((m) => m.id != _member.id).toList(),
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  String _ageText() {
    final age = _ageCalculator.calculate(
      birthDate: _member.birthDate,
    );

    if (age.years > 0) {
      return '${age.years} سال و ${age.months} ماه';
    }

    if (age.months > 0) {
      return '${age.months} ماه و ${age.days} روز';
    }

    return '${age.days} روز';
  }

  ScheduleStatus _status(ScheduleItem item) {
    if (item.isCompleted) {
      return ScheduleStatus.completed;
    }

    final today = JalaliDateUtils.today().toDateTime();
    final due = item.dueDate.toDateTime();

    if (due.isBefore(today)) {
      return ScheduleStatus.overdue;
    }

    if (due.year == today.year &&
        due.month == today.month &&
        due.day == today.day) {
      return ScheduleStatus.due;
    }

    return ScheduleStatus.upcoming;
  }

  String _statusLabel(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.upcoming:
        return 'پیش رو';
      case ScheduleStatus.due:
        return 'امروز';
      case ScheduleStatus.overdue:
        return 'نیاز به بررسی';
      case ScheduleStatus.completed:
        return 'انجام شد';
    }
  }

  Color _statusColor(
    ScheduleStatus status,
    BuildContext context,
  ) {
    switch (status) {
      case ScheduleStatus.upcoming:
        return Theme.of(context).colorScheme.primary;
      case ScheduleStatus.due:
        return Theme.of(context).colorScheme.tertiary;
      case ScheduleStatus.overdue:
        return Theme.of(context).colorScheme.error;
      case ScheduleStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    final upcoming = items
        .where(
          (i) =>
              !i.isCompleted &&
              _status(i) != ScheduleStatus.overdue,
        )
        .toList();

    final next = upcoming.isEmpty ? null : upcoming.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(_member.fullName),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _member.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'تولد: ${_member.birthDate}',
                            ),
                            Text(
                              'سن: ${_ageText()}',
                            ),
                            Text(
                              'جنسیت: ${_member.sex == PersonSex.female ? 'زن' : 'مرد'}',
                            ),
                            if (_member.isPregnant)
                              const Text(
                                'بارداری: ثبت شده',
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (next != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.event_available_outlined,
                          ),
                          title: const Text('مراقبت بعدی'),
                          subtitle: Text(
                            '${next.title} — ${next.dueDate}',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'برنامه مراقبت و واکسیناسیون',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      const Text(
                        'موردی برای نمایش وجود ندارد.',
                      ),
                    for (final item in items) _itemCard(item),
                    const SizedBox(height: 16),
                    const Text(
                      'این برنامه برای یادآوری و نظم‌دهی مراقبت‌هاست و جایگزین ارزیابی پزشک یا ماما نیست.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _itemCard(ScheduleItem item) {
    final status = _status(item);
    final color = _statusColor(status, context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            item.category == ScheduleCategory.vaccination
                ? Icons.vaccines_outlined
                : item.category ==
                        ScheduleCategory.pregnancy
                    ? Icons.pregnant_woman_outlined
                    : Icons.health_and_safety_outlined,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(
          [
            if (item.dose != null) item.dose!,
            'تاریخ: ${item.dueDate}',
            if (item.description != null) item.description!,
          ].join('\n'),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusLabel(status),
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
            Checkbox(
              value: item.isCompleted,
              onChanged: (_) => _toggleCompleted(item),
            ),
          ],
        ),
      ),
    );
  }
}
