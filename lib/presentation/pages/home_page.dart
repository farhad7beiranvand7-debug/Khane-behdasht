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
  final FamilyMemberStore _store = const FamilyMemberStore();

  List<Person> _members = [];
  bool _loading = true;

  static const _background = Color(0xFFF7F9F6);
  static const _green = Color(0xFF527A18);
  static const _text = Color(0xFF263238);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final members = widget.loadMembers != null
        ? await widget.loadMembers!()
        : await _store.load();

    if (!mounted) return;

    setState(() {
      _members = members;
      _loading = false;
    });
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

  Future<void> _addMember() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MemberFormPage(),
      ),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'خانه بهداشت خانه دوست',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _green,
                ),
              )
            : RefreshIndicator(
                color: _green,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                  children: [
                    _AddMemberButton(
                      onTap: _addMember,
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                      title: 'اعضای خانواده',
                    ),
                    const SizedBox(height: 10),
                    if (_members.isEmpty)
                      const _EmptyMembers()
                    else
                      ..._members.map(
                        (member) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MemberTile(
                            member: member,
                            onTap: () => _openMember(member),
                          ),
                        ),
                      ),
                    if (_members.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'کارهای سلامت خانواده',
                      ),
                      const SizedBox(height: 10),
                      ..._familyTasks().map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: _TaskTile(
                            task: task,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailPage(
                                    person: task.member,
                                    service: task.service,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  List<_FamilyTask> _familyTasks() {
    const engine = HealthServiceEngine();
    final result = <_FamilyTask>[];

    for (final member in _members) {
      final services = engine.servicesFor(member);

      for (final service in services) {
        if (!_showOnHome(service)) continue;

        result.add(
          _FamilyTask(
            member: member,
            service: service,
          ),
        );
      }
    }

    return result;
  }

  bool _showOnHome(HealthService service) {
    if (service.category == HealthServiceCategory.vaccination) {
      return service.shortTitle.contains('کودک') ||
          service.title.contains('کودک');
    }

    if (service.id.toLowerCase().contains('vaccine_status')) {
      return false;
    }

    if (service.shortTitle.contains('وضعیت واکسن') ||
        service.title.contains('وضعیت واکسن')) {
      return false;
    }

    if (service.shortTitle == 'واکسیناسیون' ||
        service.title == 'واکسیناسیون') {
      return false;
    }

    return service.status == HealthServiceStatus.action ||
        service.status == HealthServiceStatus.upcoming;
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

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF527A18),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'افزودن عضو خانواده',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF263238),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.onTap,
  });

  final Person member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3DF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  member.sex == PersonSex.female
                      ? Icons.female_rounded
                      : Icons.male_rounded,
                  color: const Color(0xFF527A18),
                  size: 24,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        color: Color(0xFF263238),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'مشاهده خدمات سلامت',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF98A2B3),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3DF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconFor(task.service.category),
                  color: const Color(0xFF527A18),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.service.shortTitle,
                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                task.member.fullName,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF98A2B3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(HealthServiceCategory category) {
    switch (category) {
      case HealthServiceCategory.vaccination:
        return Icons.vaccines_outlined;
      case HealthServiceCategory.pregnancy:
        return Icons.pregnant_woman_outlined;
      case HealthServiceCategory.women:
        return Icons.female_outlined;
      case HealthServiceCategory.child:
        return Icons.child_care_outlined;
      case HealthServiceCategory.adolescent:
        return Icons.school_outlined;
      case HealthServiceCategory.youth:
        return Icons.person_outline_rounded;
      case HealthServiceCategory.elderly:
        return Icons.elderly_outlined;
      case HealthServiceCategory.oralHealth:
        return Icons.health_and_safety_outlined;
      case HealthServiceCategory.nutrition:
        return Icons.restaurant_outlined;
      case HealthServiceCategory.mentalHealth:
        return Icons.psychology_outlined;
      case HealthServiceCategory.screening:
        return Icons.search_outlined;
      case HealthServiceCategory.periodicCare:
        return Icons.health_and_safety_outlined;
    }
  }
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: Color(0xFF527A18),
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'هنوز عضوی به خانواده اضافه نشده است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF344054),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
