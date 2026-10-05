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
static const _darkGreen = Color(0xFF175C35);
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

Future<void> addMember() async {
final member = await Navigator.of(context).push<Person>(
MaterialPageRoute(
builder: () => const MemberFormPage(),
),
);

if (member != null) {
  await _load();
}

}

Future<void> openMember(Person member) async {
await Navigator.of(context).push(
MaterialPageRoute(
builder: () => PersonSchedulePage(member: member),
),
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
    builder: (_) => HealthServicesPage(
      person: _members.first,
    ),
  ),
);

}

void _openMembers() {
if (_members.isEmpty) {
_addMember();
return;
}

_openMember(_members.first);

}

void _message(String text) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
behavior: SnackBarBehavior.floating,
content: Text(text),
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
                24,
              ),
              children: [
                _WelcomeHeader(
                  hasMembers: _members.isNotEmpty,
                  onAddMember: _addMember,
                ),

                const SizedBox(height: 22),

                _SectionHeader(
                  title: 'دسترسی سریع',
                  icon: Icons.grid_view_rounded,
                ),

                const SizedBox(height: 10),

                _QuickActions(
                  onServices: _openServices,
                  onMembers: _openMembers,
                  onVaccination: _openServices,
                  onScreening: _openServices,
                  onPregnancy: _openServices,
                  onMentalHealth: _openServices,
                ),

                const SizedBox(height: 24),

                _SectionHeader(
                  title: 'مراقبت‌های پیش رو',
                  icon: Icons.event_available_outlined,
                  actionText: importantServices.isNotEmpty
                      ? 'همه'
                      : null,
                  onAction: _openServices,
                ),

                const SizedBox(height: 10),

                if (importantServices.isEmpty)
                  _EmptyCareCard(
                    hasMembers: _members.isNotEmpty,
                    onAdd: _addMember,
                    onOpen: _openServices,
                  )
                else
                  ...importantServices.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CareCard(
                        service: service,
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                _SectionHeader(
                  title: 'افراد تحت پوشش',
                  icon: Icons.groups_outlined,
                  actionText: 'افزودن',
                  onAction: _addMember,
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 18),

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
scrolledUnderElevation: 0,
backgroundColor: _green,
foregroundColor: Colors.white,
toolbarHeight: 60,
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
message(
'جستجوی خدمات در نسخه بعدی فعال می‌شود.',
);
},
icon: const Icon(
Icons.search_rounded,
),
),
IconButton(
tooltip: 'تنظیمات',
onPressed: () {
Navigator.of(context).push(
MaterialPageRoute(
builder: () => const AboutPage(),
),
);
},
icon: const Icon(
Icons.settings_outlined,
),
),
const SizedBox(width: 4),
],
);
}
}

class _WelcomeHeader extends StatelessWidget {
const _WelcomeHeader({
required this.hasMembers,
required this.onAddMember,
});

final bool hasMembers;
final VoidCallback onAddMember;

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.fromLTRB(
18,
17,
18,
16,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFFE4EAE6),
),
),
child: Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: const Color(0xFFEAF5EE),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.favorite_outline_rounded,
color: Color(0xFF287A4B),
size: 26,
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
hasMembers
? 'سلامت خانواده'
: 'به خانه بهداشت خوش آمدید',
style: const TextStyle(
color: Color(0xFF174B2C),
fontSize: 17,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 4),
Text(
hasMembers
? 'مراقبت‌های سلامت خانواده را یکجا ببینید.'
: 'برای شروع، اولین فرد خانواده را اضافه کنید.',
style: const TextStyle(
color: Color(0xFF68756D),
fontSize: 12.5,
height: 1.4,
),
),
],
),
),
if (!hasMembers)
IconButton(
onPressed: onAddMember,
tooltip: 'افزودن فرد',
icon: const Icon(
Icons.add_circle_outline_rounded,
color: Color(0xFF287A4B),
),
),
],
),
);
}
}

class _SectionHeader extends StatelessWidget {
const _SectionHeader({
required this.title,
required this.icon,
this.actionText,
this.onAction,
});

final String title;
final IconData icon;
final String? actionText;
final VoidCallback? onAction;

@override
Widget build(BuildContext context) {
return Row(
children: [
Container(
width: 30,
height: 30,
decoration: BoxDecoration(
color: const Color(0xFFEAF5EE),
borderRadius: BorderRadius.circular(9),
),
child: Icon(
icon,
color: const Color(0xFF287A4B),
size: 18,
),
),
const SizedBox(width: 9),
Expanded(
child: Text(
title,
style: const TextStyle(
color: Color(0xFF1E4F32),
fontSize: 15,
fontWeight: FontWeight.w800,
),
),
),
if (actionText != null && onAction != null)
TextButton(
onPressed: onAction,
style: TextButton.styleFrom(
foregroundColor: const Color(0xFF287A4B),
padding: const EdgeInsets.symmetric(
horizontal: 6,
),
minimumSize: Size.zero,
tapTargetSize:
MaterialTapTargetSize.shrinkWrap,
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
actionText!,
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.w700,
),
),
const SizedBox(width: 2),
const Icon(
Icons.chevron_left_rounded,
size: 18,
),
],
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
title: 'مراقبت‌ها',
icon: Icons.medical_services_outlined,
onTap: onServices,
),
_QuickActionData(
title: 'افراد خانواده',
icon: Icons.groups_outlined,
onTap: onMembers,
),
_QuickActionData(
title: 'واکسیناسیون',
icon: Icons.vaccines_outlined,
onTap: onVaccination,
),
_QuickActionData(
title: 'غربالگری',
icon: Icons.search_rounded,
onTap: onScreening,
),
_QuickActionData(
title: 'بارداری',
icon: Icons.pregnant_woman_outlined,
onTap: onPregnancy,
),
_QuickActionData(
title: 'سلامت روان',
icon: Icons.psychology_outlined,
onTap: onMentalHealth,
),
];

return GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: items.length,
  gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.08,
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
required this.title,
required this.icon,
required this.onTap,
});

final String title;
final IconData icon;
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
borderRadius: BorderRadius.circular(15),
child: InkWell(
onTap: data.onTap,
borderRadius: BorderRadius.circular(15),
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 6,
vertical: 10,
),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(15),
border: Border.all(
color: const Color(0xFFE4EAE6),
),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
width: 39,
height: 39,
decoration: BoxDecoration(
color: const Color(0xFFEAF5EE),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
data.icon,
color: const Color(0xFF287A4B),
size: 21,
),
),
const SizedBox(height: 7),
Text(
data.title,
maxLines: 1,
overflow: TextOverflow.ellipsis,
textAlign: TextAlign.center,
style: const TextStyle(
color: Color(0xFF39463E),
fontSize: 11.5,
fontWeight: FontWeight.w700,
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

final color = isAction
    ? const Color(0xFFC45567)
    : const Color(0xFFB27A2D);

final background = isAction
    ? const Color(0xFFFCEFF2)
    : const Color(0xFFFFF6E7);

return Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  child: InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4EAE6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _serviceIcon(service.category),
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF29342E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  service.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF717B75),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isAction
                      ? 'نیازمند توجه'
                      : 'در برنامه مراقبت',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF9AA49E),
            size: 21,
          ),
        ],
      ),
    ),
  ),
);

}

IconData _serviceIcon(
HealthServiceCategory category,
) {
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
height: 104,
child: ListView.separated(
scrollDirection: Axis.horizontal,
itemCount: members.length + 1,
separatorBuilder: (_, __) =>
const SizedBox(width: 8),
itemBuilder: (context, index) {
if (index == members.length) {
return _AddMemberMiniCard(
onTap: onAdd,
);
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
const _MemberMiniCard({
required this.member,
required this.onTap,
});

final Person member;
final VoidCallback onTap;

@override
Widget build(BuildContext context) {
final isFemale =
member.sex == PersonSex.female;

return Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(15),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      width: 108,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE4EAE6),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isFemale
                ? const Color(0xFFFBEFF4)
                : const Color(0xFFEEF5FA),
            child: Icon(
              isFemale
                  ? Icons.woman_outlined
                  : Icons.person_outline,
              color: isFemale
                  ? const Color(0xFFC25C7A)
                  : const Color(0xFF3877A5),
              size: 21,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF354039),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
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
borderRadius: BorderRadius.circular(15),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(15),
child: Container(
width: 96,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(15),
border: Border.all(
color: const Color(0xFFBFDAC8),
),
),
child: const Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.add_circle_outline_rounded,
color: Color(0xFF287A4B),
size: 29,
),
SizedBox(height: 6),
Text(
'افزودن فرد',
style: TextStyle(
color: Color(0xFF287A4B),
fontWeight: FontWeight.w700,
fontSize: 11.5,
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
return Material(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
child: InkWell(
onTap: onAdd,
borderRadius: BorderRadius.circular(16),
child: Container(
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
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
color: const Color(0xFFEAF5EE),
borderRadius: BorderRadius.circular(12),
),
child: const Icon(
Icons.person_add_alt_1_outlined,
color: Color(0xFF287A4B),
),
),
const SizedBox(width: 11),
const Expanded(
child: Text(
'اولین فرد خانواده را اضافه کنید.',
style: TextStyle(
color: Color(0xFF465149),
fontSize: 12.5,
fontWeight: FontWeight.w600,
),
),
),
const Icon(
Icons.chevron_left_rounded,
color: Color(0xFF287A4B),
),
],
),
),
),
);
}
}

class _EmptyCareCard extends StatelessWidget {
const _EmptyCareCard({
required this.hasMembers,
required this.onAdd,
required this.onOpen,
});

final bool hasMembers;
final VoidCallback onAdd;
final VoidCallback onOpen;

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
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
color: const Color(0xFFEAF5EE),
borderRadius: BorderRadius.circular(12),
),
child: const Icon(
Icons.event_note_outlined,
color: Color(0xFF287A4B),
),
),
const SizedBox(width: 11),
Expanded(
child: Text(
hasMembers
? 'در حال حاضر مراقبت ویژه‌ای برای نمایش وجود ندارد.'
: 'برای نمایش مراقبت‌ها، یک فرد اضافه کنید.',
style: const TextStyle(
color: Color(0xFF68736C),
fontSize: 11.5,
height: 1.45,
),
),
),
if (!hasMembers)
TextButton(
onPressed: onAdd,
child: const Text('افزودن'),
)
else
IconButton(
onPressed: onOpen,
icon: const Icon(
Icons.chevron_left_rounded,
),
color: const Color(0xFF287A4B),
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
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
color: const Color(0xFFF0F6F2),
borderRadius: BorderRadius.circular(15),
border: Border.all(
color: const Color(0xFFDCE9E0),
),
),
child: const Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.info_outline_rounded,
color: Color(0xFF287A4B),
size: 20,
),
SizedBox(width: 9),
Expanded(
child: Text(
'خدمات نمایش‌داده‌شده بر اساس اطلاعات فرد، سن و شرایط ثبت‌شده تنظیم می‌شوند.',
style: TextStyle(
color: Color(0xFF65736A),
fontSize: 10.5,
height: 1.5,
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
height: 64,
elevation: 0,
backgroundColor: Colors.white,
indicatorColor: const Color(0xFFE1F0E6),
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
icon: Icon(
Icons.home_outlined,
),
selectedIcon: Icon(
Icons.home_rounded,
color: Color(0xFF287A4B),
),
label: 'خانه',
),
NavigationDestination(
icon: Icon(
Icons.calendar_month_outlined,
),
selectedIcon: Icon(
Icons.calendar_month_rounded,
color: Color(0xFF287A4B),
),
label: 'مراقبت‌ها',
),
NavigationDestination(
icon: Icon(
Icons.groups_outlined,
),
selectedIcon: Icon(
Icons.groups_rounded,
color: Color(0xFF287A4B),
),
label: 'افراد',
),
NavigationDestination(
icon: Icon(
Icons.settings_outlined,
),
selectedIcon: Icon(
Icons.settings_rounded,
color: Color(0xFF287A4B),
),
label: 'تنظیمات',
),
],
);
}
}
