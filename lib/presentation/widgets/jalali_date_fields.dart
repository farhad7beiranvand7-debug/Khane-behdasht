import 'package:flutter/material.dart';

import '../../core/calendar/jalali_birth_date.dart';
import '../../core/utils/persian_digits.dart';

class JalaliDateFields extends StatefulWidget {
  const JalaliDateFields({
    super.key,
    this.initialDate,
    required this.label,
    this.onChanged,
    this.optional = false,
  });

  final JalaliBirthDate? initialDate;
  final String label;
  final ValueChanged<JalaliBirthDate?>? onChanged;
  final bool optional;

  @override
  State<JalaliDateFields> createState() => _JalaliDateFieldsState();
}

class _JalaliDateFieldsState extends State<JalaliDateFields> {
  late final TextEditingController _year;
  late final TextEditingController _month;
  late final TextEditingController _day;

  @override
  void initState() {
    super.initState();
    _year = TextEditingController(text: widget.initialDate?.year.toString() ?? '');
    _month = TextEditingController(text: widget.initialDate?.month.toString() ?? '');
    _day = TextEditingController(text: widget.initialDate?.day.toString() ?? '');
  }

  @override
  void dispose() {
    _year.dispose();
    _month.dispose();
    _day.dispose();
    super.dispose();
  }

  JalaliBirthDate? get value {
    final y = int.tryParse(PersianDigits.normalize(_year.text.trim()));
    final m = int.tryParse(PersianDigits.normalize(_month.text.trim()));
    final d = int.tryParse(PersianDigits.normalize(_day.text.trim()));
    if (y == null || m == null || d == null) return null;
    try {
      return JalaliBirthDate(year: y, month: m, day: d);
    } catch (_) {
      return null;
    }
  }

  void _changed() => widget.onChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _field(_year, 'سال')),
            const SizedBox(width: 8),
            Expanded(child: _field(_month, 'ماه')),
            const SizedBox(width: 8),
            Expanded(child: _field(_day, 'روز')),
          ],
        ),
        if (widget.optional)
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('اختیاری'),
          ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: (_) => _changed(),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
