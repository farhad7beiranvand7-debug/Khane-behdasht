import 'package:flutter/material.dart';

import '../../core/health/health_service_engine.dart';
import '../../data/family_member_store.dart';
import '../../domain/models/health_service.dart';
import '../../domain/models/person.dart';
import 'about_page.dart';
import 'health_services_page.dart';
import 'member_form_page.dart';
import 'person_schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _green = Color(0xFF287A4B);
  static const _background = Color(0xFFF7F9F8);

  final _store = const FamilyMemberStore();
  final _serviceEngine = const HealthServiceEngine();

  List<Person> _members = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final members = await _store.load();

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

      _message('خواندن اطلاعات خانواده انجام نشد.');
    }
  }

  Future<void> _addMember() async {
    final member = await Navigator.of(context).push<Person>(
      MaterialPageRoute(
        builder: (_) => const MemberFormPage(),
      ),
    );

    if (member != null) {
      await _load();
    }
  }

  Future<void> _openMember(Person member) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonSchedulePage(member: member),
      ),
    );

    await _load();
  }

  void _openMembers() {
    if (_members.isEmpty) {
      _addMember();
      return;
    }

    _openMember(_members.first);
  }

  void _openServices() {
    if (_members.isEmpty) {
      _addMember();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthServicesPage(
          person: _members.first,
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstMember = _members.isEmpty ? null : _members.first;

    final services = firstMember == null
        ? const <HealthService>[]
        : _serviceEngine.servicesFor(firstMember);

    final importantServices = services
        .where(
          (service) =>
              service.status == HealthServiceStatus.action ||
              service.status == HealthServiceStatus.upcoming,
        )
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: _load,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    28,
                  ),
                  children: [
                    const _WelcomeHeader(),

                    const SizedBox(height: 24),

                    const _SectionHeader(
                      title: 'دسترسی سریع',
                    ),

                    const SizedBox(height: 12),

                    _QuickActions(
                      onServices: _openServices,
                      onMembers: _openMembers,
                      onVaccination: _openServices,
                      onScreening: _openServices,
                      onPregnancy: _openServices,
                      onMentalHealth: _openServices,
                    ),

                    const SizedBox(height: 26),

                    _SectionHeader(
                      title: 'مراقبت‌های پیش رو',
                      actionText: 'مشاهده همه',
                      onAction: _openServices,
                    ),

                    const SizedBox(height: 12),

                    if (importantServices.isEmpty)
                      _EmptyCareCard(
                        onAdd: _addMember,
                      )
                    else
                      ...importantServices.map(
                        (service) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: _CareCard(
                            service: service,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    _SectionHeader(
                      title: 'افراد تحت پوشش',
                      actionText: 'افزودن',
                      onAction: _addMember,
                    ),

                    const SizedBox(height: 12),

                    if (_members.isEmpty)
                      _EmptyMembersCard(
                        onAdd: _addMember,
                      )
                    else
                      _MembersStrip(
                        members: _members,
                        onMemberTap: _openMember,
                        onAdd: _addMember,
                      ),

                    const SizedBox(height: 20),

                    const _InfoCard(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        onHome: () {},
        onCalendar: _openServices,
        onMembers: _openMembers,
        onSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AboutPage(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _green,
      foregroundColor: Colors.white,
      toolbarHeight: 64,
      titleSpacing: 16,
      title: const Row(
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 25,
          ),
          SizedBox(width: 9),
          Text(
            'خانه بهداشت',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'جستجو',
          onPressed: () {
            _message(
              'جستجوی خدمات در نسخه بعدی فعال می‌شود.',
            );
          },
          icon: const Icon(
            Icons.search_rounded,
          ),
        ),
        IconButton(
          tooltip: 'درباره برنامه',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AboutPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.info_outline_rounded,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سلام',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Color(0xFF18352A),
          ),
        ),
        SizedBox(height: 5),
        Text(
          'مراقبت‌های سلامت خانواده را ساده‌تر دنبال کنید.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF68756F),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF24352D),
            ),
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF287A4B),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
            ),
            child: Text(
              actionText!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onServices,
    required this.onMembers,
    required this.onVaccination,
    required this.onScreening,
    required this.onPregnancy,
    required this.onMentalHealth,
  });

  final VoidCallback onServices;
  final VoidCallback onMembers;
  final VoidCallback onVaccination;
  final VoidCallback onScreening;
  final VoidCallback onPregnancy;
  final VoidCallback onMentalHealth;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionData(
        icon: Icons.medical_services_outlined,
        title: 'مراقبت‌ها',
        onTap: onServices,
      ),
      _QuickActionData(
        icon: Icons.groups_outlined,
        title: 'خانواده',
        onTap: onMembers,
      ),
      _QuickActionData(
        icon: Icons.vaccines_outlined,
        title: 'واکسیناسیون',
        onTap: onVaccination,
      ),
      _QuickActionData(
        icon: Icons.fact_check_outlined,
        title: 'غربالگری',
        onTap: onScreening,
      ),
      _QuickActionData(
        icon: Icons.pregnant_woman_outlined,
        title: 'بارداری',
        onTap: onPregnancy,
      ),
      _QuickActionData(
        icon: Icons.psychology_outlined,
        title: 'سلامت روان',
        onTap: onMentalHealth,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        return _QuickActionCard(
          data: items[index],
        );
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.data,
  });

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4EAE6),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data.icon,
                size: 25,
                color: const Color(0xFF287A4B),
              ),
              const SizedBox(height: 8),
              Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF33423A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  const _CareCard({
    required this.service,
  });

  final HealthService service;

  @override
  Widget build(BuildContext context) {
    final isAction =
        service.status == HealthServiceStatus.action;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4EAE6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isAction
                  ? const Color(0xFFFFF4E8)
                  : const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isAction
                  ? Icons.priority_high_rounded
                  : Icons.event_available_outlined,
              color: isAction
                  ? const Color(0xFFB56A19)
                  : const Color(0xFF287A4B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.shortTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26362E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF738078),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersStrip extends StatelessWidget {
  const _MembersStrip({
    required this.members,
    required this.onMemberTap,
    required this.onAdd,
  });

  final List<Person> members;
  final Future<void> Function(Person member) onMemberTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length + 1,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == members.length) {
            return _AddMemberMiniCard(
              onTap: onAdd,
            );
          }

          return _MemberMiniCard(
            member: members[index],
            onTap: () => onMemberTap(members[index]),
          );
        },
      ),
    );
  }
}

class _MemberMiniCard extends StatelessWidget {
  const _MemberMiniCard({
    required this.member,
    required this.onTap,
  });

  final Person member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 145,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4EAE6),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEAF5EE),
                child: Icon(
                  Icons.person_outline,
                  color: Color(0xFF287A4B),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  member.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF33423A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMemberMiniCard extends StatelessWidget {
  const _AddMemberMiniCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD7E2DB),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Color(0xFF287A4B),
                size: 25,
              ),
              SizedBox(height: 6),
              Text(
                'افزودن',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF33423A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMembersCard extends StatelessWidget {
  const _EmptyMembersCard({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4EAE6),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_add_alt_1_outlined,
            color: Color(0xFF287A4B),
            size: 30,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'برای شروع، یک نفر را به خانواده اضافه کنید.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5F6C65),
                height: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCareCard extends StatelessWidget {
  const _EmptyCareCard({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4EAE6),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_note_outlined,
            color: Color(0xFF287A4B),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'برای نمایش مراقبت‌های متناسب، ابتدا یک نفر اضافه کنید.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF68756F),
                height: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF287A4B),
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'خدمات نمایش داده‌شده بر اساس سن، جنسیت و شرایط ثبت‌شده فرد تنظیم می‌شوند.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF476155),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onHome,
    required this.onCalendar,
    required this.onMembers,
    required this.onSettings,
  });

  final VoidCallback onHome;
  final VoidCallback onCalendar;
  final VoidCallback onMembers;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            onHome();
            break;
          case 1:
            onCalendar();
            break;
          case 2:
            onMembers();
            break;
          case 3:
            onSettings();
            break;
        }
      },
      height: 68,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE3F1E8),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'خانه',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event_rounded),
          label: 'مراقبت‌ها',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups_rounded),
          label: 'خانواده',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info_rounded),
          label: 'درباره',
        ),
      ],
    );
  }
}
