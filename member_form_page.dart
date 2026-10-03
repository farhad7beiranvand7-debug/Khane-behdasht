import 'package:flutter/material.dart';

import '../../core/calendar/jalali_birth_date.dart';
import '../../data/family_member_store.dart';
import '../../domain/models/person.dart';
import '../widgets/jalali_date_fields.dart';

class MemberFormPage extends StatefulWidget {
  const MemberFormPage({super.key, this.initialMember});

  final Person? initialMember;

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  final _store = const FamilyMemberStore();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  JalaliBirthDate? _birthDate;
  JalaliBirthDate? _lmpDate;
  late PersonSex _sex;
  late Set<HealthCondition> _conditions;
  bool _pregnant = false;
  bool _saving = false;

  bool get _editing => widget.initialMember != null;

  @override
  void initState() {
    super.initState();
    final member = widget.initialMember;
    _firstName = TextEditingController(text: member?.firstName ?? '');
    _lastName = TextEditingController(text: member?.lastName ?? '');
    _birthDate = member?.birthDate;
    _lmpDate = member?.lmpDate;
    _sex = member?.sex ?? PersonSex.female;
    _conditions = {...(member?.conditions ?? {HealthCondition.none})};
    _pregnant = member?.isPregnant ?? false;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    if (firstName.isEmpty || lastName.isEmpty || _birthDate == null) {
      _message('نام، نام خانوادگی و تاریخ تولد دقیق را وارد کنید.');
      return;
    }
    if (_sex == PersonSex.male && _pregnant) {
      _message('وضعیت بارداری فقط برای جنسیت زن قابل ثبت است.');
      return;
    }
    if (_pregnant && _lmpDate == null) {
      _message('برای ثبت بارداری، تاریخ اولین روز آخرین قاعدگی را وارد کنید.');
      return;
    }

    setState(() => _saving = true);
    try {
      final members = await _store.load();
      final member = Person(
        id: widget.initialMember?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        firstName: firstName,
        lastName: lastName,
        birthDate: _birthDate!,
        sex: _sex,
        conditions: _conditions.isEmpty ? {HealthCondition.none} : _conditions,
        isPregnant: _pregnant,
        lmpDate: _pregnant ? _lmpDate : null,
      );
      final updated = [
        for (final item in members)
          if (item.id != member.id) item,
        member,
      ];
      await _store.save(updated);
      if (!mounted) return;
      Navigator.of(context).pop(member);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _message('ذخیره اطلاعات انجام نشد.');
      }
    }
  }

  void _toggleCondition(HealthCondition condition, bool selected) {
    setState(() {
      if (condition == HealthCondition.none) {
        _conditions = selected ? {HealthCondition.none} : {};
        return;
      }
      _conditions.remove(HealthCondition.none);
      if (selected) {
        _conditions.add(condition);
      } else {
        _conditions.remove(condition);
      }
      if (_conditions.isEmpty) _conditions.add(HealthCondition.none);
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _conditionLabel(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.none:
        return 'بدون بیماری زمینه‌ای مؤثر بر مراقبت';
      case HealthCondition.hypertension:
        return 'فشار خون بالا';
      case HealthCondition.diabetes:
        return 'دیابت';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'ویرایش فرد' : 'افزودن عضو خانواده')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _firstName,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'نام', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastName,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'نام خانوادگی', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            JalaliDateFields(
              label: 'تاریخ تولد دقیق شمسی',
              initialDate: _birthDate,
              onChanged: (value) => _birthDate = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PersonSex>(
              initialValue: _sex,
              decoration: const InputDecoration(labelText: 'جنسیت', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: PersonSex.female, child: Text('زن')),
                DropdownMenuItem(value: PersonSex.male, child: Text('مرد')),
              ],
              onChanged: _saving ? null : (value) => setState(() => _sex = value ?? PersonSex.female),
            ),
            const SizedBox(height: 16),
            Text('شرایط زمینه‌ای', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final condition in HealthCondition.values)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _conditions.contains(condition),
                title: Text(_conditionLabel(condition)),
                onChanged: _saving ? null : (value) => _toggleCondition(condition, value ?? false),
              ),
            if (_sex == PersonSex.female) ...[
              const Divider(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('آیا باردار است؟'),
                value: _pregnant,
                onChanged: _saving ? null : (value) => setState(() => _pregnant = value),
              ),
              if (_pregnant) ...[
                const SizedBox(height: 8),
                JalaliDateFields(
                  label: 'اولین روز آخرین قاعدگی',
                  initialDate: _lmpDate,
                  onChanged: (value) => _lmpDate = value,
                ),
              ],
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_saving ? 'در حال ذخیره...' : 'ذخیره اطلاعات'),
            ),
          ],
        ),
      ),
    );
  }
}
