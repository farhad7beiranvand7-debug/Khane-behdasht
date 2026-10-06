import 'package:flutter/material.dart';

import '../../core/health/health_service_engine.dart';
import '../../data/family_member_store.dart';
import '../../domain/models/health_service.dart';
import '../../domain/models/person.dart';
import 'health_services_page.dart';
import 'member_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.loadMembers,
  });

  final Future<List<Person>> Function()? loadMembers;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _background = Color(0xFFF9FBF7);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  final FamilyMemberStore _store = FamilyMemberStore();
  const HealthServiceEngine _engine = HealthServiceEngine();

  List<Person> _members = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final members = widget.loadMembers != null
          ? await widget.loadMembers!()
          : await _store.load();

      if (!mounted) return;

      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خواندن اطلاعات خانواده انجام نشد.'),
        ),
      );
    }
  }

  Future<void> _addMember() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MemberFormPage(),
      ),
    );

    await _load();
  }

  Future<void> _openMember(Person member) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthServicesPage(
          person: member,
        ),
      ),
    );

    await _load();
  }

  List<_FamilyTask> _familyTasks() {
    final tasks = <_FamilyTask>[];

    for (final member in _members) {
      final services = _engine
          .servicesFor(member)
          .where(
            (service) =>
                service.status == HealthServiceStatus.action ||
                service.status == HealthServiceStatus.upcoming,
          )
          .toList();

      for (final service in services) {
        tasks.add(
          _FamilyTask(
            member: member,
            service: service,
          ),
        );
      }
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _familyTasks();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          'خانه بهداشت خانه دوست',
          style: TextStyle(
            color: _text,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                color: _darkGreen,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _sectionTitle(
                      title: 'اعضای خانواده',
                    ),
                    const SizedBox(height: 10),
                    if (_members.isEmpty)
                      _EmptyFamilyCard(
                        onAdd: _addMember,
                      )
                    else ...[
                      ..._members.map(
                        (member) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MemberTile(
                            member: member,
                            onTap: () => _openMember(member),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _AddMemberButton(
                        onTap: _addMember,
                      ),
                    ],
                    const SizedBox(height: 28),
                    _sectionTitle(
                      title: 'کارهای سلامت خانواده',
                    ),
                    const SizedBox(height: 10),
                    if (_members.isEmpty)
                      const _EmptyTasksCard()
                    else if (tasks.isEmpty)
                      const _NoTaskCard()
                    else
                      ...tasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TaskTile(
                            task: task,
                            onTap: () => _openMember(task.member),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
  }) {
    return Text(
      title,
      style: const TextStyle(
        color: _text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FamilyTask {
  const _FamilyTask({
    required this.member,
    required this.service,
  });

  final Person member;
  final HealthService service;
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.onTap,
  });

  final Person member;
  final VoidCallback onTap;

  static const _green = Color(0xFFA6E22E);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7D8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: _green,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onTap,
  });

  final _FamilyTask task;
  final VoidCallback onTap;

  static const _green = Color(0xFFA6E22E);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    final isAction =
        task.service.status == HealthServiceStatus.action;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 42,
                decoration: BoxDecoration(
                  color: isAction ? Colors.orange : _green,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.member.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.service.shortTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  static const _green = Color(0xFF527A18);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(
        Icons.person_add_alt_1_rounded,
        size: 20,
      ),
      label: const Text(
        'افزودن عضو خانواده',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _green,
        side: const BorderSide(
          color: Color(0xFFD5E8B8),
        ),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _EmptyFamilyCard extends StatelessWidget {
  const _EmptyFamilyCard({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 42,
            color: Color(0xFFA6E22E),
          ),
          const SizedBox(height: 10),
          const Text(
            'هنوز عضوی از خانواده اضافه نشده است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'برای شروع، اعضای خانواده را اضافه کنید.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          _AddMemberButton(
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard();

  @override
  Widget build(BuildContext context) {
    return const _SimpleMessageCard(
      text: 'پس از افزودن اعضای خانواده، خدمات موردنیاز آن‌ها اینجا نمایش داده می‌شود.',
    );
  }
}

class _NoTaskCard extends StatelessWidget {
  const _NoTaskCard();

  @override
  Widget build(BuildContext context) {
    return const _SimpleMessageCard(
      text: 'در حال حاضر موردی برای پیگیری در فهرست خانواده ثبت نشده است.',
    );
  }
}

class _SimpleMessageCard extends StatelessWidget {
  const _SimpleMessageCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF667085),
          fontSize: 13,
          height: 1.7,
        ),
      ),
    );
  }
}
