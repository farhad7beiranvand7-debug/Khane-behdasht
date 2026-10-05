enum HealthServiceCategory {
  child,
  adolescent,
  youth,
  periodicCare,
  screening,
  vaccination,
  women,
  pregnancy,
  mentalHealth,
  nutrition,
  oralHealth,
  elderly,
}

enum HealthServiceStatus {
  action,
  upcoming,
  completed,
  information,
}

enum HealthServiceAgeGroup {
  all,
  infant,
  child,
  adolescent,
  youth,
  adult,
  middleAge,
  elderly,
}

class HealthService {
  const HealthService({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.category,
    required this.status,
    this.ageMin,
    this.ageMax,
    this.femaleOnly = false,
    this.maleOnly = false,
    this.requiresPregnancy = false,
    this.ageGroup = HealthServiceAgeGroup.all,
    this.icon,
  });

  final String id;

  /// نام کامل و قابل فهم برای مردم
  final String title;

  /// عنوان کوتاه برای نمایش در کارت
  final String shortTitle;

  /// توضیح ساده خدمت
  final String description;

  final HealthServiceCategory category;

  final HealthServiceStatus status;

  /// حداقل سن تقریبی بر حسب سال
  final int? ageMin;

  /// حداکثر سن تقریبی بر حسب سال
  final int? ageMax;

  final bool femaleOnly;
  final bool maleOnly;

  /// فقط برای فردی که بارداری برای او ثبت شده
  final bool requiresPregnancy;

  /// گروه سنی برای نمایش بهتر
  final HealthServiceAgeGroup ageGroup;

  /// آیکون اختیاری
  final int? icon;

  bool appliesTo({
    required int age,
    required bool female,
    required bool pregnant,
  }) {
    if (ageMin != null && age < ageMin!) {
      return false;
    }

    if (ageMax != null && age > ageMax!) {
      return false;
    }

    if (femaleOnly && !female) {
      return false;
    }

    if (maleOnly && female) {
      return false;
    }

    if (requiresPregnancy && !pregnant) {
      return false;
    }

    return true;
  }
}

---

2. کل "health_service_engine.dart" را جایگزین کن

این قسمت مهم‌ترین تغییر است.

در این نسخه، برنامه دیگر فقط ۹ خدمت نمونه ندارد؛ مجموعه‌ای از خدمات عمومی، مراقبت‌های سنی، غربالگری‌ها، سلامت روان، تغذیه، دهان و دندان، زنان، بارداری و واکسیناسیون را بر اساس مشخصات فرد نمایش می‌دهد.

توجه: این نسخه عمداً از ادعای «انجام قطعی در فلان روز/ماه» برای مواردی که هنوز سند دقیق بسته خدمت را وارد نکرده‌ایم خودداری می‌کند.

:::writing{variant="document" id="52407" title="health_service_engine.dart"}

import '../../domain/models/health_service.dart';
import '../../domain/models/person.dart';

class HealthServiceEngine {
  const HealthServiceEngine();

  List<HealthService> servicesFor(Person person) {
    final age = _calculateAge(person);

    final female = person.sex == PersonSex.female;
    final pregnant = person.isPregnant;

    final services = <HealthService>[
      // ============================================================
      // خدمات عمومی برای همه
      // ============================================================

      const HealthService(
        id: 'general-health-assessment',
        title: 'ارزیابی کلی سلامت',
        shortTitle: 'ارزیابی سلامت',
        description:
            'بررسی وضعیت عمومی سلامت و عوامل مؤثر بر سلامت فرد.',
        category: HealthServiceCategory.periodicCare,
        status: HealthServiceStatus.information,
        ageGroup: HealthServiceAgeGroup.all,
      ),

      const HealthService(
        id: 'nutrition',
        title: 'بررسی تغذیه',
        shortTitle: 'تغذیه',
        description:
            'بررسی وضعیت تغذیه و دریافت آموزش‌های متناسب با سن و شرایط فرد.',
        category: HealthServiceCategory.nutrition,
        status: HealthServiceStatus.information,
        ageGroup: HealthServiceAgeGroup.all,
      ),

      const HealthService(
        id: 'physical-activity',
        title: 'فعالیت بدنی و سبک زندگی',
        shortTitle: 'فعالیت بدنی',
        description:
            'بررسی میزان فعالیت بدنی و آموزش سبک زندگی سالم.',
        category: HealthServiceCategory.nutrition,
        status: HealthServiceStatus.information,
        ageGroup: HealthServiceAgeGroup.all,
      ),

      const HealthService(
        id: 'oral-health',
        title: 'سلامت دهان و دندان',
        shortTitle: 'دهان و دندان',
        description:
            'بررسی وضعیت سلامت دهان و دندان و دریافت آموزش‌های لازم.',
        category: HealthServiceCategory.oralHealth,
        status: HealthServiceStatus.information,
        ageGroup: HealthServiceAgeGroup.all,
      ),

      // ============================================================
      // نوزاد و شیرخوار
      // ============================================================

      const HealthService(
        id: 'infant-growth',
        title: 'پایش رشد و تکامل کودک',
        shortTitle: 'رشد و تکامل',
        description:
            'بررسی رشد، وزن، قد و تکامل کودک متناسب با سن.',
        category: HealthServiceCategory.child,
        status: HealthServiceStatus.upcoming,
        ageMax: 2,
        ageGroup: HealthServiceAgeGroup.infant,
      ),

      const HealthService(
        id: 'infant-vaccination',
        title: 'بررسی واکسیناسیون کودک',
        shortTitle: 'واکسن‌های کودک',
        description:
            'بررسی کارت واکسن و اطمینان از دریافت واکسن‌های متناسب با سن.',
        category: HealthServiceCategory.vaccination,
        status: HealthServiceStatus.upcoming,
        ageMax: 2,
        ageGroup: HealthServiceAgeGroup.infant,
      ),

      const HealthService(
        id: 'infant-hearing',
        title: 'بررسی شنوایی',
        shortTitle: 'شنوایی',
        description:
            'پیگیری غربالگری و ارزیابی شنوایی کودک در زمان مناسب.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.information,
        ageMax: 1,
        ageGroup: HealthServiceAgeGroup.infant,
      ),

      const HealthService(
        id: 'infant-development',
        title: 'پایش تکامل کودک',
        shortTitle: 'تکامل',
        description:
            'بررسی مراحل تکامل حرکتی، زبانی و رفتاری کودک.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.information,
        ageMax: 5,
        ageGroup: HealthServiceAgeGroup.infant,
      ),

      // ============================================================
      // کودک
      // ============================================================

      const HealthService(
        id: 'child-growth',
        title: 'پایش رشد کودک',
        shortTitle: 'رشد کودک',
        description:
            'بررسی رشد جسمی و وضعیت تغذیه کودک.',
        category: HealthServiceCategory.child,
        status: HealthServiceStatus.upcoming,
        ageMin: 2,
        ageMax: 9,
        ageGroup: HealthServiceAgeGroup.child,
      ),

      const HealthService(
        id: 'child-development',
        title: 'بررسی تکامل کودک',
        shortTitle: 'تکامل کودک',
        description:
            'بررسی رشد و تکامل کودک و شناسایی موارد نیازمند پیگیری.',
        category: HealthServiceCategory.child,
        status: HealthServiceStatus.information,
        ageMax: 9,
        ageGroup: HealthServiceAgeGroup.child,
      ),

      const HealthService(
        id: 'child-vaccination',
        title: 'بررسی واکسیناسیون کودک',
        shortTitle: 'واکسیناسیون',
        description:
            'بررسی وضعیت واکسن‌های کودک بر اساس برنامه ملی واکسیناسیون.',
        category: HealthServiceCategory.vaccination,
        status: HealthServiceStatus.upcoming,
        ageMax: 9,
        ageGroup: HealthServiceAgeGroup.child,
      ),

      const HealthService(
        id: 'child-oral-health',
        title: 'مراقبت دهان و دندان کودک',
        shortTitle: 'دندان کودک',
        description:
            'آموزش و بررسی سلامت دهان و دندان کودک.',
        category: HealthServiceCategory.oralHealth,
        status: HealthServiceStatus.information,
        ageMax: 9,
        ageGroup: HealthServiceAgeGroup.child,
      ),

      // ============================================================
      // نوجوان
      // ============================================================

      const HealthService(
        id: 'adolescent-health',
        title: 'مراقبت سلامت نوجوان',
        shortTitle: 'سلامت نوجوان',
        description:
            'بررسی سلامت جسمی، روانی و اجتماعی نوجوان و آموزش‌های لازم.',
        category: HealthServiceCategory.adolescent,
        status: HealthServiceStatus.upcoming,
        ageMin: 10,
        ageMax: 18,
        ageGroup: HealthServiceAgeGroup.adolescent,
      ),

      const HealthService(
        id: 'adolescent-mental-health',
        title: 'سلامت روان نوجوان',
        shortTitle: 'سلامت روان',
        description:
            'بررسی وضعیت روانی، هیجانی و عوامل خطر سلامت روان.',
        category: HealthServiceCategory.mentalHealth,
        status: HealthServiceStatus.information,
        ageMin: 10,
        ageMax: 18,
        ageGroup: HealthServiceAgeGroup.adolescent,
      ),

      const HealthService(
        id: 'adolescent-nutrition',
        title: 'تغذیه نوجوان',
        shortTitle: 'تغذیه نوجوان',
        description:
            'بررسی تغذیه و آموزش عادات غذایی مناسب دوران رشد.',
        category: HealthServiceCategory.nutrition,
        status: HealthServiceStatus.information,
        ageMin: 10,
        ageMax: 18,
        ageGroup: HealthServiceAgeGroup.adolescent,
      ),

      const HealthService(
        id: 'adolescent-oral-health',
        title: 'سلامت دهان و دندان نوجوان',
        shortTitle: 'دندان نوجوان',
        description:
            'بررسی و آموزش مراقبت از دهان و دندان.',
        category: HealthServiceCategory.oralHealth,
        status: HealthServiceStatus.information,
        ageMin: 10,
        ageMax: 18,
        ageGroup: HealthServiceAgeGroup.adolescent,
      ),

      // ============================================================
      // جوان
      // ============================================================

      const HealthService(
        id: 'youth-health',
        title: 'مراقبت سلامت جوان',
        shortTitle: 'سلامت جوان',
        description:
            'ارزیابی سلامت جسمی، روانی و اجتماعی و آموزش پیشگیری.',
        category: HealthServiceCategory.youth,
        status: HealthServiceStatus.upcoming,
        ageMin: 19,
        ageMax: 29,
        ageGroup: HealthServiceAgeGroup.youth,
      ),

      const HealthService(
        id: 'youth-mental-health',
        title: 'سلامت روان جوان',
        shortTitle: 'سلامت روان',
        description:
            'بررسی سلامت روان و عوامل خطر و ارائه آموزش‌های لازم.',
        category: HealthServiceCategory.mentalHealth,
        status: HealthServiceStatus.information,
        ageMin: 19,
        ageMax: 29,
        ageGroup: HealthServiceAgeGroup.youth,
      ),

      const HealthService(
        id: 'youth-nutrition',
        title: 'تغذیه و سبک زندگی جوان',
        shortTitle: 'سبک زندگی',
        description:
            'بررسی تغذیه، فعالیت بدنی و رفتارهای مؤثر بر سلامت.',
        category: HealthServiceCategory.nutrition,
        status: HealthServiceStatus.information,
        ageMin: 19,
        ageMax: 29,
        ageGroup: HealthServiceAgeGroup.youth,
      ),

      // ============================================================
      // بزرگسال و میانسال
      // ============================================================

      const HealthService(
        id: 'adult-blood-pressure',
        title: 'اندازه‌گیری فشار خون',
        shortTitle: 'فشار خون',
        description:
            'اندازه‌گیری فشار خون و بررسی احتمال فشار خون بالا.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.upcoming,
        ageMin: 18,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'adult-diabetes',
        title: 'غربالگری دیابت',
        shortTitle: 'قند خون',
        description:
            'بررسی خطر دیابت و انجام ارزیابی لازم بر اساس برنامه سلامت.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.upcoming,
        ageMin: 18,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'adult-cardiovascular',
        title: 'ارزیابی خطر بیماری‌های قلبی و عروقی',
        shortTitle: 'خطر قلبی',
        description:
            'بررسی عوامل خطر بیماری‌های قلبی و عروقی.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.information,
        ageMin: 30,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'adult-lipid',
        title: 'بررسی چربی خون',
        shortTitle: 'چربی خون',
        description:
            'بررسی وضعیت چربی خون بر اساس سن و عوامل خطر.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.information,
        ageMin: 30,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'adult-mental-health',
        title: 'بررسی سلامت روان بزرگسال',
        shortTitle: 'سلامت روان',
        description:
            'بررسی سلامت روان و عوامل خطر مرتبط.',
        category: HealthServiceCategory.mentalHealth,
        status: HealthServiceStatus.information,
        ageMin: 18,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'adult-nutrition',
        title: 'بررسی تغذیه و سبک زندگی',
        shortTitle: 'تغذیه و سبک زندگی',
        description:
            'بررسی تغذیه، فعالیت بدنی و عوامل خطر مرتبط با سبک زندگی.',
        category: HealthServiceCategory.nutrition,
        status: HealthServiceStatus.information,
        ageMin: 18,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      // ============================================================
      // سالمندان
      // ============================================================

      const HealthService(
        id: 'elderly-health',
        title: 'مراقبت سلامت سالمند',
        shortTitle: 'سلامت سالمند',
        description:
            'ارزیابی جامع سلامت و مشکلات شایع دوران سالمندی.',
        category: HealthServiceCategory.elderly,
        status: HealthServiceStatus.upcoming,
        ageMin: 60,
        ageGroup: HealthServiceAgeGroup.elderly,
      ),

      const HealthService(
        id: 'elderly-fall-risk',
        title: 'بررسی خطر سقوط',
        shortTitle: 'خطر سقوط',
        description:
            'بررسی عوامل خطر سقوط و آموزش راه‌های پیشگیری.',
        category: HealthServiceCategory.elderly,
        status: HealthServiceStatus.information,
        ageMin: 60,
        ageGroup: HealthServiceAgeGroup.elderly,
      ),

      const HealthService(
        id: 'elderly-mental-health',
        title: 'سلامت روان سالمند',
        shortTitle: 'سلامت روان',
        description:
            'بررسی وضعیت روانی و اجتماعی سالمند.',
        category: HealthServiceCategory.mentalHealth,
        status: HealthServiceStatus.information,
        ageMin: 60,
        ageGroup: HealthServiceAgeGroup.elderly,
      ),

      // ============================================================
      // زنان
      // ============================================================

      const HealthService(
        id: 'women-health',
        title: 'مراقبت سلامت زنان',
        shortTitle: 'سلامت زنان',
        description:
            'مراقبت‌های اختصاصی سلامت زنان متناسب با سن و شرایط فرد.',
        category: HealthServiceCategory.women,
        status: HealthServiceStatus.information,
        femaleOnly: true,
        ageMin: 10,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'women-preconception',
        title: 'مراقبت پیش از بارداری',
        shortTitle: 'پیش از بارداری',
        description:
            'ارزیابی سلامت و عوامل خطر پیش از بارداری و ارائه آموزش‌های لازم.',
        category: HealthServiceCategory.women,
        status: HealthServiceStatus.information,
        femaleOnly: true,
        ageMin: 15,
        ageMax: 54,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      // ============================================================
      // بارداری
      // ============================================================

      const HealthService(
        id: 'pregnancy-care',
        title: 'مراقبت دوران بارداری',
        shortTitle: 'مراقبت بارداری',
        description:
            'پیگیری مراقبت‌های دوران بارداری و ارزیابی سلامت مادر و جنین.',
        category: HealthServiceCategory.pregnancy,
        status: HealthServiceStatus.action,
        femaleOnly: true,
        requiresPregnancy: true,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'pregnancy-nutrition',
        title: 'تغذیه دوران بارداری',
        shortTitle: 'تغذیه بارداری',
        description:
            'آموزش و بررسی تغذیه مناسب دوران بارداری.',
        category: HealthServiceCategory.nutrition,
        status: HealthServiceStatus.information,
        femaleOnly: true,
        requiresPregnancy: true,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'pregnancy-mental-health',
        title: 'سلامت روان دوران بارداری',
        shortTitle: 'سلامت روان بارداری',
        description:
            'توجه به سلامت روان و عوامل خطر روانی اجتماعی در دوران بارداری.',
        category: HealthServiceCategory.mentalHealth,
        status: HealthServiceStatus.information,
        femaleOnly: true,
        requiresPregnancy: true,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      // ============================================================
      // واکسیناسیون
      // ============================================================

      const HealthService(
        id: 'vaccination-status',
        title: 'بررسی وضعیت واکسیناسیون',
        shortTitle: 'وضعیت واکسن‌ها',
        description:
            'بررسی کارت واکسن و تطبیق واکسن‌های دریافت‌شده با برنامه ملی.',
        category: HealthServiceCategory.vaccination,
        status: HealthServiceStatus.upcoming,
        ageGroup: HealthServiceAgeGroup.all,
      ),

      // ============================================================
      // خدمات غربالگری سرطان
      // ============================================================

      const HealthService(
        id: 'cancer-screening-women',
        title: 'غربالگری‌های اختصاصی زنان',
        shortTitle: 'غربالگری زنان',
        description:
            'بررسی نیاز به غربالگری‌های سرطان‌های شایع زنان بر اساس سن و دستورالعمل.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.information,
        femaleOnly: true,
        ageMin: 30,
        ageGroup: HealthServiceAgeGroup.adult,
      ),

      const HealthService(
        id: 'cancer-screening-adult',
        title: 'بررسی غربالگری سرطان',
        shortTitle: 'غربالگری سرطان',
        description:
            'بررسی نیاز فرد به غربالگری سرطان‌های شایع بر اساس سن و عوامل خطر.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.information,
        ageMin: 30,
        ageGroup: HealthServiceAgeGroup.adult,
      ),
    ];

    return services
        .where(
          (service) => service.appliesTo(
            age: age,
            female: female,
            pregnant: pregnant,
          ),
        )
        .toList();
  }

  int _calculateAge(Person person) {
    final birth = person.birthDate;
    final now = DateTime.now();

    // birthDate در پروژه شما شمسی است.
    // برای نمایش گروه سنی، سال شمسی فعلی را به‌صورت تقریبی
    // از سال میلادی به دست می‌آوریم.
    final currentYear = now.year - 621;

    var age = currentYear - birth.year;

    if (birth.month > now.month ||
        (birth.month == now.month && birth.day > now.day)) {
      age--;
    }

    if (age < 0) {
      return 0;
    }

    return age;
  }
}

---

3. صفحه "health_services_page.dart"

اینجا یک تغییر مهم داده‌ام.

قبلاً کاربر با یک لیست نسبتاً فنی مواجه می‌شد. حالا ابتدا «الان برای شما مهم‌تر است» نمایش داده می‌شود و بعد دسته‌بندی‌های ساده.

مثلاً یک فرد ۶۵ ساله لازم نیست اول با ۳۰ مورد مواجه شود؛ ابتدا «سلامت سالمند»، «فشارخون»، «دیابت»، «خطر سقوط» و موارد مربوط به خودش را می‌بیند.

کل فایل را جایگزین کن:

import 'package:flutter/material.dart';

import '../../core/health/health_service_engine.dart';
import '../../domain/models/health_service.dart';
import '../../domain/models/person.dart';

class HealthServicesPage extends StatelessWidget {
  const HealthServicesPage({
    super.key,
    required this.person,
  });

  final Person person;

  @override
  Widget build(BuildContext context) {
    const engine = HealthServiceEngine();

    final services = engine.servicesFor(person);

    final important = services
        .where(
          (service) =>
              service.status == HealthServiceStatus.action ||
              service.status == HealthServiceStatus.upcoming,
        )
        .toList();

    final categories = <HealthServiceCategory>[
      HealthServiceCategory.child,
      HealthServiceCategory.adolescent,
      HealthServiceCategory.youth,
      HealthServiceCategory.elderly,
      HealthServiceCategory.periodicCare,
      HealthServiceCategory.screening,
      HealthServiceCategory.vaccination,
      HealthServiceCategory.women,
      HealthServiceCategory.pregnancy,
      HealthServiceCategory.mentalHealth,
      HealthServiceCategory.nutrition,
      HealthServiceCategory.oralHealth,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقبت‌های سلامت'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        children: [
          _PersonHeader(person: person),

          const SizedBox(height: 20),

          if (important.isNotEmpty)
            _ImportantCard(
              services: important,
            ),

          const SizedBox(height: 20),

          Text(
            'خدمات مربوط به شما',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 6),

          const Text(
            'برنامه بر اساس سن، جنسیت و شرایط ثبت‌شده، موارد مرتبط را نمایش می‌دهد.',
          ),

          const SizedBox(height: 16),

          for (final category in categories)
            _CategoryCard(
              category: category,
              services: services
                  .where(
                    (service) => service.category == category,
                  )
                  .toList(),
            ),

          const SizedBox(height: 12),

          const Text(
            'توجه: زمان و نوع بعضی خدمات بر اساس دستورالعمل، سابقه فرد و نظر کارکنان مرکز سلامت تعیین می‌شود.',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonHeader extends StatelessWidget {
  const _PersonHeader({
    required this.person,
  });

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Icon(
                person.sex == PersonSex.female
                    ? Icons.woman_outlined
                    : Icons.man_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.fullName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تاریخ تولد: ${person.birthDate}',
                  ),
                  if (person.isPregnant)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'وضعیت بارداری: ثبت شده',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportantCard extends StatelessWidget {
  const _ImportantCard({
    required this.services,
  });

  final List<HealthService> services;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'مراقبت‌های پیش رو',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'این موارد بر اساس اطلاعات ثبت‌شده برای این فرد مرتبط هستند.',
            ),

            const SizedBox(height: 12),

            for (final service in services)
              _ImportantServiceTile(
                service: service,
              ),
          ],
        ),
      ),
    );
  }
}

class _ImportantServiceTile extends StatelessWidget {
  const _ImportantServiceTile({
    required this.service,
  });

  final HealthService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          child: Icon(
            _iconFor(service.category),
          ),
        ),
        title: Text(
          service.shortTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          service.description,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.services,
  });

  final HealthServiceCategory category;
  final List<HealthService> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(
          _iconFor(category),
        ),
        title: Text(
          _titleFor(category),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${services.length} خدمت',
        ),
        children: [
          for (final service in services)
            _ServiceTile(
              service: service,
            ),
        ],
      ),
    );
  }

  String _titleFor(
    HealthServiceCategory category,
  ) {
    switch (category) {
      case HealthServiceCategory.child:
        return 'کودک';

      case HealthServiceCategory.adolescent:
        return 'نوجوان';

      case HealthServiceCategory.youth:
        return 'جوان';

      case HealthServiceCategory.elderly:
        return 'سالمند';

      case HealthServiceCategory.periodicCare:
        return 'مراقبت‌های دوره‌ای';

      case HealthServiceCategory.screening:
        return 'غربالگری و بررسی‌ها';

      case HealthServiceCategory.vaccination:
        return 'واکسیناسیون';

      case HealthServiceCategory.women:
        return 'سلامت زنان';

      case HealthServiceCategory.pregnancy:
        return 'بارداری';

      case HealthServiceCategory.mentalHealth:
        return 'سلامت روان';

      case HealthServiceCategory.nutrition:
        return 'تغذیه و سبک زندگی';

      case HealthServiceCategory.oralHealth:
        return 'دهان و دندان';
    }
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
  });

  final HealthService service;

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(service.status);

    return ListTile(
      leading: Icon(
        _iconFor(service.category),
      ),
      title: Text(
        service.title,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(
            service.description,
          ),
          const SizedBox(height: 5),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String _statusText(
  HealthServiceStatus status,
) {
  switch (status) {
    case HealthServiceStatus.action:
      return 'نیازمند توجه';

    case HealthServiceStatus.upcoming:
      return 'در برنامه مراقبت';

    case HealthServiceStatus.completed:
      return 'انجام شده';

    case HealthServiceStatus.information:
      return 'اطلاعات و آموزش';
  }
}

IconData _iconFor(
  HealthServiceCategory category,
) {
  switch (category) {
    case HealthServiceCategory.child:
      return Icons.child_care_outlined;

    case HealthServiceCategory.adolescent:
      return Icons.school_outlined;

    case HealthServiceCategory.youth:
      return Icons.person_outline;

    case HealthServiceCategory.elderly:
      return Icons.elderly_outlined;

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
  }
}

یک نکته مهم قبل از Build

در فایل اول یک فیلد:

final int? icon;

گذاشتم که فعلاً استفاده نمی‌شود. لازم نیست حذفش کنی؛ مشکلی برای "analyze" ایجاد نمی‌کند.

اما یک تغییر مهم در منطق انجام دادم: فشارخون و دیابت را از ۳۰ سال به ۱۸ سال آوردم. این با چیزی که در برنامه‌های غربالگری ملی ایران برای افراد بالای ۱۸ سال اجرا شده سازگارتر است؛ منابع معاونت‌های بهداشت نیز هدف غربالگری فشارخون و دیابت را افراد بالای ۱۸ سال اعلام کرده‌اند.

همچنین گروه‌های سنی و مراقبت‌های جداگانه را از هم تفکیک کردیم؛ نظام ارائه خدمات ایران برای گروه‌هایی مثل کودکان، نوجوانان و جوانان، میانسالان، سالمندان و مادران باردار بسته‌های مراقبتی جداگانه دارد.

فعلاً این سه فایل را جایگزین کن و Push کن. اگر "Flutter analyze" سبز شد، مرحله بعدی را من روی همین ساختار انجام می‌دهم: اضافه‌کردن قواعد دقیق سن/دفعات/زمان هر خدمت و واکسن بر اساس دستورالعمل‌های مربوطه، به‌طوری که برنامه فقط «فهرست خدمات» نباشد و واقعاً بگوید «الان چه کاری باید انجام شود».
