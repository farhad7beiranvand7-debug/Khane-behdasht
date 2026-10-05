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
  static const _green = Color(0xFF2E7D4F);
  static const _lightGreen = Color(0xFFF1F8F3);
  static const _background = Color(0xFFF9FBFA);

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
      setState(() => _loading = false);
      _message('خواندن اطلاعات خانواده انجام نشد.');
    }
  }

  Future<void> _addMember() async {
    final member = await Navigator.of(context).push<Person>(
      MaterialPageRoute(builder: (_) => const MemberFormPage()),
    );
    if (member != null) await _load();
  }

  Future<void> _openMember(Person member) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PersonSchedulePage(member: member)),
    );
    await _load();
  }

  void _openServices() {
    if (_members.isEmpty) {
      _addMember();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthServicesPage(person: _members.first),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    _GreetingCard(),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      icon: Icons.bolt_rounded,
                      title: 'دسترسی سریع',
                    ),
                    const SizedBox(height: 12),
                    _QuickActions(
                      onServices: _openServices,
                      onMembers: () => _openMembers(),
                      onVaccination: () => _openServices(),
                      onScreening: () => _openServices(),
                      onPregnancy: () => _openServices(),
                      onMentalHealth: () => _openServices(),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'مراقبت‌های پیش رو',
                      icon: Icons.event_available_outlined,
                      actionText: 'مشاهده همه',
                      onAction: _openServices,
                    ),
                    const SizedBox(height: 12),
                    if (importantServices.isEmpty)
                      _EmptyCareCard(onAdd: _addMember)
                    else
                      ...importantServices.map(
                        (service) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CareCard(service: service),
                        ),
                      ),
                    const SizedBox(height: 14),
                    _SectionHeader(
                      title: 'افراد تحت پوشش',
                      icon: Icons.groups_2_outlined,
                      actionText: 'افزودن',
                      onAction: _addMember,
                    ),
                    const SizedBox(height: 12),
                    if (_members.isEmpty)
                      _EmptyMembersCard(onAdd: _addMember)
                    else
                      _MembersStrip(
                        members: _members,
                        onMemberTap: _openMember,
                        onAdd: _addMember,
                      ),
                    const SizedBox(height: 18),
                    _InfoCard(),
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
            MaterialPageRoute(builder: (_) => const AboutPage()),
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
      toolbarHeight: 68,
      titleSpacing: 14,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 19),
                SizedBox(width: 6),
                Text(
                  'پزشک خانواده',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'جستجو',
          onPressed: () => _message('جستجوی خدمات در نسخه بعدی فعال می‌شود.'),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'تنظیمات',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            );
          },
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _openMembers() {
    if (_members.isEmpty) {
      _addMember();
      return;
    }
    _openMember(_members.first);
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFF0F9F2), Color(0xFFE5F4E9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9EBDD)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام و خوش آمدید',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF174B2C),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'سلامت شما، اولویت ماست',
                  style: TextStyle(
                    color: Color(0xFF47705A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'خانه بهداشت پزشک خانواده',
                    style: TextStyle(
                      color: Color(0xFF2E7D4F),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              size: 38,
              color: Color(0xFF2E7D4F),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D4F), size: 21),
        const SizedBox(width: 7),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF205A37),
              ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.actionText,
    required this.onAction,
  });

  final String title;
  final IconData icon;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D4F), size: 20),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF205A37),
                ),
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D4F),
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.chevron_left_rounded, size: 19),
          label: Text(actionText),
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
        'خدمات سلامت',
        Icons.medical_services_outlined,
        const Color(0xFFEAF5EF),
        const Color(0xFF2E7D4F),
        onServices,
      ),
      _QuickActionData(
        'افراد من',
        Icons.groups_2_outlined,
        const Color(0xFFEEF5FA),
        const Color(0xFF3877A5),
        onMembers,
      ),
      _QuickActionData(
        'واکسیناسیون',
        Icons.vaccines_outlined,
        const Color(0xFFF3EFF9),
        const Color(0xFF79549C),
        onVaccination,
      ),
      _QuickActionData(
        'غربالگری‌ها',
        Icons.search_rounded,
        const Color(0xFFEAF7F6),
        const Color(0xFF248B86),
        onScreening,
      ),
      _QuickActionData(
        'بارداری',
        Icons.pregnant_woman_outlined,
        const Color(0xFFFBEFF4),
        const Color(0xFFC25C7A),
        onPregnancy,
      ),
      _QuickActionData(
        'سلامت روان',
        Icons.psychology_outlined,
        const Color(0xFFFFF4E8),
        const Color(0xFFB77A35),
        onMentalHealth,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuickActionCard(data: item);
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData(
    this.title,
    this.icon,
    this.background,
    this.iconColor,
    this.onTap,
  );

  final String title;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7ECE9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.iconColor, size: 23),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: Color(0xFF7E8B83),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  const _CareCard({required this.service});

  final HealthService service;

  @override
  Widget build(BuildContext context) {
    final isAction = service.status == HealthServiceStatus.action;
    final color = isAction ? const Color(0xFFC65368) : const Color(0xFFC58A32);
    final bg = isAction ? const Color(0xFFFDF0F3) : const Color(0xFFFFF7E9);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8ECE9)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _serviceIcon(service.category),
                color: color,
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF68736C),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAction ? 'نیازمند توجه' : 'در برنامه مراقبت',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF87928B),
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(HealthServiceCategory category) {
    switch (category) {
      case HealthServiceCategory.child:
        return Icons.child_care_outlined;
      case HealthServiceCategory.adolescent:
        return Icons.school_outlined;
      case HealthServiceCategory.youth:
        return Icons.person_outline;
      case HealthServiceCategory.periodicCare:
        return Icons.monitor_heart_outlined;
      case HealthServiceCategory.screening:
        return Icons.search_rounded;
      case HealthServiceCategory.vaccination:
        return Icons.vaccines_outlined;
      case HealthServiceCategory.women:
        return Icons.woman_outlined;
      case HealthServiceCategory.pregnancy:
        return Icons.pregnant_woman_outlined;
      case HealthServiceCategory.mentalHealth:
        return Icons.psychology_outlined;
      case HealthServiceCategory.nutrition:
        return Icons.restaurant_outlined;
      case HealthServiceCategory.oralHealth:
        return Icons.health_and_safety_outlined;
      case HealthServiceCategory.elderly:
        return Icons.elderly_outlined;
    }
  }
}

class _MembersStrip extends StatelessWidget {
  const _MembersStrip({
    required this.members,
    required this.onMemberTap,
    required this.onAdd,
  });

  final List<Person> members;
  final ValueChanged<Person> onMemberTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == members.length) {
            return _AddMemberMiniCard(onTap: onAdd);
          }
          final member = members[index];
          return _MemberMiniCard(
            member: member,
            onTap: () => onMemberTap(member),
          );
        },
      ),
    );
  }
}

class _MemberMiniCard extends StatelessWidget {
  const _MemberMiniCard({required this.member, required this.onTap});

  final Person member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFemale = member.sex == PersonSex.female;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 112,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7ECE9)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: isFemale
                    ? const Color(0xFFFBEFF4)
                    : const Color(0xFFEEF5FA),
                child: Icon(
                  isFemale ? Icons.woman_outlined : Icons.person_outline,
                  color: isFemale
                      ? const Color(0xFFC25C7A)
                      : const Color(0xFF3877A5),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                member.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'مشاهده مراقبت‌ها',
                style: TextStyle(
                  color: Color(0xFF7A857E),
                  fontSize: 9,
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
  const _AddMemberMiniCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFCFE2D4),
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFEAF5EF),
                child: Icon(
                  Icons.add_rounded,
                  color: Color(0xFF2E7D4F),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'افزودن فرد',
                style: TextStyle(
                  color: Color(0xFF2E7D4F),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
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
  const _EmptyMembersCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECE9)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFEAF5EF),
            child: Icon(Icons.group_add_outlined, color: Color(0xFF2E7D4F)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'برای شروع، اولین فرد خانواده را اضافه کنید.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.chevron_left_rounded),
            color: const Color(0xFF2E7D4F),
          ),
        ],
      ),
    );
  }
}

class _EmptyCareCard extends StatelessWidget {
  const _EmptyCareCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECE9)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFF1F8F3),
            child: Icon(
              Icons.event_note_outlined,
              color: Color(0xFF2E7D4F),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'برای نمایش مراقبت‌های مرتبط، یک فرد به خانواده اضافه کنید.',
              style: TextStyle(fontSize: 12.5, height: 1.5),
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEBDF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF2E7D4F),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توجه',
                  style: TextStyle(
                    color: Color(0xFF205A37),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'زمان و نوع بعضی خدمات بر اساس دستورالعمل، سابقه فرد و نظر کارکنان مرکز سلامت تعیین می‌شود.',
                  style: TextStyle(
                    color: Color(0xFF65736A),
                    fontSize: 11.5,
                    height: 1.55,
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
      height: 68,
      onDestinationSelected: (index) {
        if (index == 0) {
          onHome();
        } else if (index == 1) {
          onCalendar();
        } else if (index == 2) {
          onMembers();
        } else if (index == 3) {
          onSettings();
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'خانه',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'برنامه‌ها',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          label: 'افراد',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'تنظیمات',
        ),
      ],
    );
  }
}
