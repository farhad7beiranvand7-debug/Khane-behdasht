import 'package:flutter/material.dart';

import '../../core/calendar/jalali_birth_date.dart';
import '../../data/family_member_store.dart';
import '../../domain/models/person.dart';

class MemberFormPage extends StatefulWidget {
  const MemberFormPage({
    super.key,
    this.person,
  });

  final Person? person;

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _background = Color(0xFFF9FBF7);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final FamilyMemberStore _store = const FamilyMemberStore();

  JalaliBirthDate? _birthDate;
  JalaliBirthDate? _lmpDate;

  PersonSex _sex = PersonSex.male;
  bool _isPregnant = false;

  Set<HealthCondition> _conditions = {
    HealthCondition.none,
  };

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final person = widget.person;

    if (person != null) {
      _firstNameController.text = person.firstName;
      _lastNameController.text = person.lastName;

      _birthDate = person.birthDate;
      _lmpDate = person.lmpDate;

      _sex = person.sex;
      _isPregnant = person.isPregnant;

      _conditions = Set<HealthCondition>.from(
        person.conditions,
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final selected = await _showDatePicker(
      title: 'تاریخ تولد',
      initialDate: _birthDate,
    );

    if (selected != null) {
      setState(() {
        _birthDate = selected;
      });
    }
  }

  Future<void> _selectLmpDate() async {
    final selected = await _showDatePicker(
      title: 'تاریخ اولین روز آخرین قاعدگی',
      initialDate: _lmpDate,
    );

    if (selected != null) {
      setState(() {
        _lmpDate = selected;
      });
    }
  }

  Future<JalaliBirthDate?> _showDatePicker({
    required String title,
    JalaliBirthDate? initialDate,
  }) async {
    final now = DateTime.now();

    var year = initialDate?.year ?? now.year - 621;
    var month = initialDate?.month ?? now.month;
    var day = initialDate?.day ?? now.day;

    final controller = TextEditingController(
      text: _formatDateValues(year, month, day),
    );

    final result = await showDialog<JalaliBirthDate>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'مثلاً 1400/05/20',
              prefixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: _darkGreen,
              ),
              filled: true,
              fillColor: _background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE4E7EC),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE4E7EC),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('انصراف'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _darkGreen,
              ),
              onPressed: () {
                final parsed = _parseDate(controller.text);

                if (parsed == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تاریخ را به شکل 1400/05/20 وارد کنید.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context, parsed);
              },
              child: const Text('تأیید'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  JalaliBirthDate? _parseDate(String value) {
    final normalized = value.trim().replaceAll('-', '/');

    final parts = normalized.split('/');

    if (parts.length != 3) return null;

    final parsedYear = int.tryParse(parts[0]);
    final parsedMonth = int.tryParse(parts[1]);
    final parsedDay = int.tryParse(parts[2]);

    if (parsedYear == null ||
        parsedMonth == null ||
        parsedDay == null) {
      return null;
    }

    if (parsedYear < 1300 || parsedYear > 1500) {
      return null;
    }

    if (parsedMonth < 1 || parsedMonth > 12) {
      return null;
    }

    if (parsedDay < 1 || parsedDay > 31) {
      return null;
    }

    return JalaliBirthDate(
      year: parsedYear,
      month: parsedMonth,
      day: parsedDay,
    );
  }

  String _formatDateValues(
    int year,
    int month,
    int day,
  ) {
    return '$year/'
        '${month.toString().padLeft(2, '0')}/'
        '${day.toString().padLeft(2, '0')}';
  }

  String _formatDate(JalaliBirthDate date) {
    return _formatDateValues(
      date.year,
      date.month,
      date.day,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      _showMessage('تاریخ تولد را وارد کنید.');
      return;
    }

    if (_sex == PersonSex.male) {
      _isPregnant = false;
      _lmpDate = null;
    }

    if (!_isPregnant) {
      _lmpDate = null;
    }

    setState(() {
      _saving = true;
    });

    try {
      final existingMembers = await _store.load();

      final person = Person(
        id: widget.person?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDate!,
        sex: _sex,
        conditions: _conditions,
        isPregnant: _isPregnant,
        lmpDate: _lmpDate,
      );

      final index = existingMembers.indexWhere(
        (item) => item.id == person.id,
      );

      if (index >= 0) {
        existingMembers[index] = person;
      } else {
        existingMembers.add(person);
      }

      await _store.save(existingMembers);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('ذخیره اطلاعات انجام نشد.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setCondition(
    HealthCondition condition,
    bool selected,
  ) {
    setState(() {
      if (condition == HealthCondition.none) {
        _conditions = {
          HealthCondition.none,
        };
        return;
      }

      _conditions.remove(HealthCondition.none);

      if (selected) {
        _conditions.add(condition);
      } else {
        _conditions.remove(condition);
      }

      if (_conditions.isEmpty) {
        _conditions.add(HealthCondition.none);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.person != null;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: Text(
          editing ? 'ویرایش فرد' : 'افزودن فرد',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              30,
            ),
            children: [
              _Header(),
              const SizedBox(height: 22),

              const _FieldLabel(
                text: 'نام',
              ),
              const SizedBox(height: 8),
              _TextField(
                controller: _firstNameController,
                hint: 'نام فرد',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'نام را وارد کنید.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 17),

              const _FieldLabel(
                text: 'نام خانوادگی',
              ),
              const SizedBox(height: 8),
              _TextField(
                controller: _lastNameController,
                hint: 'نام خانوادگی',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'نام خانوادگی را وارد کنید.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 17),

              const _FieldLabel(
                text: 'تاریخ تولد',
              ),
              const SizedBox(height: 8),

              _DateField(
                value: _birthDate == null
                    ? null
                    : _formatDate(_birthDate!),
                hint: 'انتخاب تاریخ تولد',
                onTap: _selectBirthDate,
              ),

              const SizedBox(height: 18),

              const _FieldLabel(
                text: 'جنسیت',
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _GenderChoice(
                      title: 'مرد',
                      icon: Icons.male_rounded,
                      selected: _sex == PersonSex.male,
                      onTap: () {
                        setState(() {
                          _sex = PersonSex.male;
                          _isPregnant = false;
                          _lmpDate = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GenderChoice(
                      title: 'زن',
                      icon: Icons.female_rounded,
                      selected: _sex == PersonSex.female,
                      onTap: () {
                        setState(() {
                          _sex = PersonSex.female;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const _FieldLabel(
                text: 'شرایط مهم سلامت',
              ),
              const SizedBox(height: 8),

              _ConditionChoice(
                title: 'هیچ‌کدام',
                icon: Icons.check_circle_outline_rounded,
                selected: _conditions.contains(
                  HealthCondition.none,
                ),
                onTap: () {
                  _setCondition(
                    HealthCondition.none,
                    true,
                  );
                },
              ),

              const SizedBox(height: 8),

              _ConditionChoice(
                title: 'فشار خون بالا',
                icon: Icons.favorite_border_rounded,
                selected: _conditions.contains(
                  HealthCondition.hypertension,
                ),
                onTap: () {
                  _setCondition(
                    HealthCondition.hypertension,
                    !_conditions.contains(
                      HealthCondition.hypertension,
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              _ConditionChoice(
                title: 'دیابت',
                icon: Icons.water_drop_outlined,
                selected: _conditions.contains(
                  HealthCondition.diabetes,
                ),
                onTap: () {
                  _setCondition(
                    HealthCondition.diabetes,
                    !_conditions.contains(
                      HealthCondition.diabetes,
                    ),
                  );
                },
              ),

              if (_sex == PersonSex.female) ...[
                const SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: const Color(0xFFE4E7EC),
                    ),
                  ),
                  child: SwitchListTile(
                    value: _isPregnant,
                    onChanged: (value) {
                      setState(() {
                        _isPregnant = value;

                        if (!value) {
                          _lmpDate = null;
                        }
                      });
                    },
                    activeThumbColor: _darkGreen,
                    title: const Text(
                      'بارداری',
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'برای نمایش مراقبت‌های اختصاصی بارداری',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                    secondary: const Icon(
                      Icons.pregnant_woman_outlined,
                      color: _darkGreen,
                    ),
                  ),
                ),

                if (_isPregnant) ...[
                  const SizedBox(height: 12),

                  const _FieldLabel(
                    text: 'اولین روز آخرین قاعدگی',
                  ),
                  const SizedBox(height: 8),

                  _DateField(
                    value: _lmpDate == null
                        ? null
                        : _formatDate(_lmpDate!),
                    hint: 'انتخاب تاریخ آخرین قاعدگی',
                    onTap: _selectLmpDate,
                  ),
                ],
              ],

              const SizedBox(height: 30),

              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          editing
                              ? 'ذخیره تغییرات'
                              : 'افزودن به خانواده',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
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

class _Header extends StatelessWidget {
  const _Header();

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.home_outlined,
              color: _darkGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'اطلاعات فرد را وارد کنید تا خدمات سلامت متناسب با سن و شرایط او نمایش داده شود.',
              style: TextStyle(
                color: _text,
                height: 1.65,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
  });

  final String text;

  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _text,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF527A18),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF527A18),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;

  static const _darkGreen = Color(0xFF527A18);
  static const _muted = Color(0xFF667085);
  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: _darkGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: TextStyle(
                  color: hasValue ? _text : _muted,
                  fontSize: 14,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
              color: _muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? _green.withValues(alpha: 0.18)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _darkGreen
                : const Color(0xFFE4E7EC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? _darkGreen
                  : const Color(0xFF667085),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: _text,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionChoice extends StatelessWidget {
  const _ConditionChoice({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? _green.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? _darkGreen
                : const Color(0xFFE4E7EC),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? _darkGreen
                  : const Color(0xFF667085),
              size: 22,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                color: _darkGreen,
                size: 21,
              ),
          ],
        ),
      ),
    );
  }
}
