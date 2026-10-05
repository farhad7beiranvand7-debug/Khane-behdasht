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
