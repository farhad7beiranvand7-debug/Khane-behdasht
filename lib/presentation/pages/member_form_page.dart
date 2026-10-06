import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

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

  final FamilyMemberStore _store = FamilyMemberStore();

  Jalali? _birthDate;
  PersonSex _sex = PersonSex.male;
  bool _isPregnant = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final person = widget.person;

    if (person != null) {
      _firstNameController.text = person.firstName;
      _lastNameController.text = person.lastName;
      _birthDate = person.birthDate;
      _sex = person.sex;
      _isPregnant = person.isPregnant;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final initialDate = _birthDate ?? Jalali.now();

    final selected = await showPersianDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: Jalali(1300, 1, 1),
      lastDate: Jalali.now(),
    );

    if (selected != null) {
      setState(() {
        _birthDate = selected;
      });
    }
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
    }

    setState(() {
      _saving = true;
    });

    try {
      final person = Person(
        id: widget.person?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDate!,
        sex: _sex,
        isPregnant: _isPregnant,
      );

      await _store.save(person);

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

  @override
  Widget build(BuildContext context) {
    final editing = widget.person != null;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        title: Text(
          editing ? 'ویرایش فرد' : 'افزودن فرد',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const _PageIntro(),
              const SizedBox(height: 24),

              _FieldLabel(text: 'نام'),
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

              const SizedBox(height: 18),

              _FieldLabel(text: 'نام خانوادگی'),
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

              const SizedBox(height: 18),

              _FieldLabel(text: 'تاریخ تولد'),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _selectBirthDate,
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
                          _birthDate == null
                              ? 'انتخاب تاریخ تولد'
                              : _formatJalali(_birthDate!),
                          style: TextStyle(
                            color: _birthDate == null
                                ? _muted
                                : _text,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
              ),

              const SizedBox(height: 18),

              _FieldLabel(text: 'جنسیت'),
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
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

              if (_sex == PersonSex.female) ...[
                const SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE4E7EC),
                    ),
                  ),
                  child: SwitchListTile(
                    value: _isPregnant,
                    onChanged: (value) {
                      setState(() {
                        _isPregnant = value;
                      });
                    },
                    activeColor: _darkGreen,
                    title: const Text(
                      'بارداری',
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'برای نمایش مراقبت‌های مربوط به بارداری',
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
                          editing ? 'ذخیره تغییرات' : 'افزودن به خانواده',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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

  String _formatJalali(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro();

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.home_health_outlined,
              color: _darkGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'اطلاعات فرد را وارد کنید تا خدمات سلامت متناسب با سن و شرایط او نمایش داده شود.',
              style: TextStyle(
                color: _text,
                height: 1.6,
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
        fontWeight: FontWeight.w700,
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
        duration: const Duration(milliseconds: 180),
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
              color: selected ? _darkGreen : const Color(0xFF667085),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: _text,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
