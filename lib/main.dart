import 'package:flutter/material.dart';

import 'core/notifications/notification_service.dart';
import 'data/family_member_store.dart';
import 'domain/models/person.dart';
import 'presentation/pages/member_form_page.dart';
import 'presentation/pages/person_schedule_page.dart';
import 'presentation/pages/about_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const KhaneBehdashtApp());
}

class KhaneBehdashtApp extends StatelessWidget {
  const KhaneBehdashtApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00695C);
    return MaterialApp(
      title: 'خانه بهداشت پزشک خانواده',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _store = const FamilyMemberStore();
  List<Person> _members = [];
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

  Future<void> _open(Person member) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PersonSchedulePage(member: member)),
    );
    await _load();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خانه بهداشت پزشک خانواده'),
        actions: [
          IconButton(
            tooltip: 'درباره برنامه',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage())),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMember,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('افزودن عضو'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Text(
                      'اعضای خانواده',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text('تاریخ تولد دقیق شمسی، مراقبت‌ها و واکسیناسیون هر فرد را در یک جا ببینید.'),
                    const SizedBox(height: 18),
                    if (_members.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.family_restroom_outlined, size: 48),
                              const SizedBox(height: 12),
                              const Text('هنوز عضوی ثبت نشده است.'),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _addMember,
                                icon: const Icon(Icons.add),
                                label: const Text('اولین عضو را اضافه کنید'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (final member in _members)
                      Card(
                        child: ListTile(
                          onTap: () => _open(member),
                          leading: CircleAvatar(child: Text(member.firstName.isEmpty ? '?' : member.firstName.substring(0, 1))),
                          title: Text(member.fullName),
                          subtitle: Text('تولد: ${member.birthDate}'),
                          trailing: const Icon(Icons.chevron_left),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'یادآوری: این برنامه ابزار یادآوری مراقبت و واکسیناسیون است و جایگزین تشخیص یا تصمیم‌گیری پزشکی نیست.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
