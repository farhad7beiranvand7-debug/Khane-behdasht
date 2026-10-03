import 'package:shamsi_date/shamsi_date.dart';

import '../../domain/models/person.dart';
import '../calendar/jalali_birth_date.dart';
import '../calendar/jalali_date_utils.dart';
import 'care_item.dart';

class ScheduleEngine {
  const ScheduleEngine();

  List<ScheduleItem> build(Person person, {Jalali? asOf}) {
    final reference = asOf ?? JalaliDateUtils.today();
    final items = <ScheduleItem>[];
    items.addAll(_vaccinations(person));
    items.addAll(_childCare(person, reference));
    items.addAll(_conditionCare(person, reference));
    if (person.isPregnant && person.lmpDate != null) {
      items.addAll(_pregnancyCare(person.lmpDate!));
    }
    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  List<ScheduleItem> _vaccinations(Person person) {
    final birth = person.birthDate.toJalali();
    const rules = <({String id, String title, String dose, int months, String description})>[
      (id: 'bcg-birth', title: 'ب.ث.ژ', dose: 'بدو تولد', months: 0, description: 'واکسن سل'),
      (id: 'hep-b-birth', title: 'هپاتیت ب', dose: 'بدو تولد', months: 0, description: 'نوبت بدو تولد'),
      (id: 'opv-birth', title: 'فلج اطفال خوراکی', dose: 'بدو تولد', months: 0, description: 'نوبت بدو تولد'),
      (id: 'pentavalent-2', title: 'پنج‌گانه', dose: 'دوز اول', months: 2, description: 'برنامه روتین کودکان'),
      (id: 'opv-2', title: 'فلج اطفال خوراکی', dose: 'نوبت ۲ ماهگی', months: 2, description: 'برنامه روتین کودکان'),
      (id: 'pentavalent-4', title: 'پنج‌گانه', dose: 'دوز دوم', months: 4, description: 'برنامه روتین کودکان'),
      (id: 'opv-4', title: 'فلج اطفال خوراکی', dose: 'نوبت ۴ ماهگی', months: 4, description: 'برنامه روتین کودکان'),
      (id: 'ipv-4', title: 'فلج اطفال تزریقی', dose: 'نوبت ۴ ماهگی', months: 4, description: 'برنامه روتین کودکان'),
      (id: 'pentavalent-6', title: 'پنج‌گانه', dose: 'دوز سوم', months: 6, description: 'برنامه روتین کودکان'),
      (id: 'opv-6', title: 'فلج اطفال خوراکی', dose: 'نوبت ۶ ماهگی', months: 6, description: 'برنامه روتین کودکان'),
      (id: 'mmr-12', title: 'MMR', dose: 'دوز اول', months: 12, description: 'سرخک، سرخجه و اوریون'),
      (id: 'dpt-18', title: 'سه‌گانه', dose: 'یادآور ۱۸ ماهگی', months: 18, description: 'دیفتری، کزاز و سیاه‌سرفه'),
      (id: 'opv-18', title: 'فلج اطفال خوراکی', dose: 'یادآور ۱۸ ماهگی', months: 18, description: 'برنامه روتین کودکان'),
      (id: 'mmr-18', title: 'MMR', dose: 'دوز دوم', months: 18, description: 'سرخک، سرخجه و اوریون'),
      (id: 'dpt-72', title: 'سه‌گانه', dose: 'یادآور ۶ سالگی', months: 72, description: 'یادآور مدرسه'),
      (id: 'opv-72', title: 'فلج اطفال خوراکی', dose: 'یادآور ۶ سالگی', months: 72, description: 'یادآور مدرسه'),
    ];

    return rules.map((rule) {
      final due = JalaliDateUtils.addMonths(birth, rule.months);
      return ScheduleItem(
        id: '${person.id}-${rule.id}',
        title: rule.title,
        category: ScheduleCategory.vaccination,
        dueDate: JalaliBirthDate.fromJalali(due),
        dose: rule.dose,
        description: rule.description,
      );
    }).toList();
  }

  List<ScheduleItem> _childCare(Person person, Jalali today) {
    final birth = person.birthDate.toJalali();
    final ageMonths = _ageInMonths(birth, today);
    if (ageMonths > 72) return const [];

    const months = [2, 4, 6, 9, 12, 15, 18, 24];
    return months.map((month) {
      final due = JalaliDateUtils.addMonths(birth, month);
      return ScheduleItem(
        id: '${person.id}-child-care-$month',
        title: 'مراقبت سلامت کودک',
        category: ScheduleCategory.care,
        dueDate: JalaliBirthDate.fromJalali(due),
        dose: '$month ماهگی',
        description: 'پایش رشد و سلامت کودک در این سن.',
      );
    }).toList();
  }

  List<ScheduleItem> _conditionCare(Person person, Jalali start) {
    final result = <ScheduleItem>[];

    if (person.conditions.contains(HealthCondition.hypertension)) {
      result.addAll(_recurringConditionItems(
        person: person,
        idPrefix: 'htn',
        title: 'پیگیری فشار خون',
        description: 'پیگیری منظم فشار خون؛ برنامه مراجعه پزشکی طبق وضعیت فرد تعیین می‌شود.',
        months: 3,
        start: start,
      ));
    }
    if (person.conditions.contains(HealthCondition.diabetes)) {
      result.addAll(_recurringConditionItems(
        person: person,
        idPrefix: 'dm',
        title: 'پیگیری دیابت',
        description: 'پیگیری منظم دیابت؛ در افراد کنترل‌شده حداقل هر سه ماه مراقبت پزشکی توصیه شده است.',
        months: 3,
        start: start,
      ));
    }
    return result;
  }

  List<ScheduleItem> _recurringConditionItems({
    required Person person,
    required String idPrefix,
    required String title,
    required String description,
    required int months,
    required Jalali start,
  }) {
    return List.generate(4, (index) {
      final due = JalaliDateUtils.addMonths(start, months * (index + 1));
      return ScheduleItem(
        id: '${person.id}-$idPrefix-${index + 1}',
        title: title,
        category: ScheduleCategory.care,
        dueDate: JalaliBirthDate.fromJalali(due),
        description: description,
      );
    });
  }

  List<ScheduleItem> _pregnancyCare(JalaliBirthDate lmp) {
    final base = lmp.toJalali();
    // The current national programme provides eight routine midwife care visits.
    // These dates mark the beginning of the published gestational windows; they are
    // reminders, not individualized clinical orders.
    const windows = <({int week, String label})>[
      (week: 6, label: 'هفته ۶ تا ۱۰'),
      (week: 16, label: 'هفته ۱۶ تا ۲۰'),
      (week: 24, label: 'هفته ۲۴ تا ۳۰'),
      (week: 31, label: 'هفته ۳۱ تا ۳۴'),
      (week: 35, label: 'هفته ۳۵ تا ۳۷'),
      (week: 38, label: 'هفته ۳۸'),
      (week: 39, label: 'هفته ۳۹'),
      (week: 40, label: 'هفته ۴۰'),
    ];
    return windows.map((window) {
      final due = JalaliDateUtils.addWeeks(base, window.week);
      return ScheduleItem(
        id: 'pregnancy-${window.week}-${base.year}-${base.month}-${base.day}',
        title: 'مراقبت دوران بارداری',
        category: ScheduleCategory.pregnancy,
        dueDate: JalaliBirthDate.fromJalali(due),
        description: 'یادآوری بازه مراقبت بارداری؛ نوع و فاصله مراجعه با نظر ماما/پزشک و شرایط مادر تعیین می‌شود.',
        dose: window.label,
      );
    }).toList();
  }

  int _ageInMonths(Jalali birth, Jalali today) {
    var months = (today.year - birth.year) * 12 + today.month - birth.month;
    if (today.day < birth.day) months--;
    return months;
  }
}
