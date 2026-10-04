import '../../domain/models/health_service.dart';
import '../../domain/models/person.dart';

class HealthServiceEngine {
  const HealthServiceEngine();

  List<HealthService> servicesFor(Person person) {
    final age = _calculateAge(person);
    final female = person.sex == PersonSex.female;
    final pregnant = person.isPregnant;

    final services = <HealthService>[
      // -----------------------------
      // مراقبت های دوره ای
      // -----------------------------

      const HealthService(
        id: 'periodic-vitals',
        title: 'بررسی فشار خون',
        shortTitle: 'فشار خون',
        description:
            'اندازه‌گیری فشار خون برای شناسایی زودهنگام فشار خون بالا.',
        category: HealthServiceCategory.periodicCare,
        status: HealthServiceStatus.action,
        ageMin: 18,
      ),

      const HealthService(
        id: 'periodic-weight',
        title: 'بررسی قد و وزن',
        shortTitle: 'قد و وزن',
        description:
            'بررسی رشد، وزن و وضعیت بدنی متناسب با سن.',
        category: HealthServiceCategory.periodicCare,
      ),

      const HealthService(
        id: 'periodic-lifestyle',
        title: 'بررسی تغذیه و فعالیت بدنی',
        shortTitle: 'سبک زندگی',
        description:
            'بررسی تغذیه، فعالیت بدنی و عادت‌های مؤثر بر سلامت.',
        category: HealthServiceCategory.nutrition,
      ),

      // -----------------------------
      // غربالگری
      // -----------------------------

      const HealthService(
        id: 'screening-diabetes',
        title: 'بررسی قند خون',
        shortTitle: 'قند خون',
        description:
            'بررسی احتمال وجود یا خطر دیابت بر اساس سن و عوامل خطر.',
        category: HealthServiceCategory.screening,
        status: HealthServiceStatus.action,
        ageMin: 30,
      ),

      const HealthService(
        id: 'screening-cardiovascular',
        title: 'بررسی خطر بیماری قلبی',
        shortTitle: 'خطر بیماری قلبی',
        description:
            'ارزیابی عوامل خطر بیماری‌های قلبی و عروقی.',
        category: HealthServiceCategory.screening,
        ageMin: 30,
      ),

      // -----------------------------
      // سلامت روان
      // -----------------------------

      const HealthService(
        id: 'mental-health',
        title: 'بررسی سلامت روان',
        shortTitle: 'سلامت روان',
        description:
            'بررسی وضعیت سلامت روان و عوامل مؤثر بر آن.',
        category: HealthServiceCategory.mentalHealth,
        ageMin: 10,
      ),

      // -----------------------------
      // سلامت دهان و دندان
      // -----------------------------

      const HealthService(
        id: 'oral-health',
        title: 'بررسی سلامت دهان و دندان',
        shortTitle: 'دهان و دندان',
        description:
            'مراقبت و بررسی سلامت دهان و دندان متناسب با سن.',
        category: HealthServiceCategory.oralHealth,
      ),

      // -----------------------------
      // زنان
      // -----------------------------

      const HealthService(
        id: 'women-health',
        title: 'مراقبت سلامت زنان',
        shortTitle: 'سلامت زنان',
        description:
            'مراقبت‌های سلامت اختصاصی زنان در سنین هدف.',
        category: HealthServiceCategory.women,
        femaleOnly: true,
        ageMin: 10,
        ageMax: 54,
      ),

      // -----------------------------
      // بارداری
      // -----------------------------

      const HealthService(
        id: 'pregnancy-care',
        title: 'مراقبت دوران بارداری',
        shortTitle: 'مراقبت بارداری',
        description:
            'مراقبت‌ها و پیگیری‌های مورد نیاز دوران بارداری.',
        category: HealthServiceCategory.pregnancy,
        femaleOnly: true,
        requiresPregnancy: true,
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

    // تبدیل تقریبی برای تعیین گروه سنی.
    // منطق دقیق سن شمسی را در مرحله بعد به AgeCalculator
    // موجود در پروژه متصل می‌کنیم.
    final currentYear = now.year - 621;

    var age = currentYear - birth.year;

    final currentMonth = now.month;
    final currentDay = now.day;

    if (birth.month > currentMonth ||
        (birth.month == currentMonth && birth.day > currentDay)) {
      age--;
    }

    if (age < 0) {
      age = 0;
    }

    return age;
  }
}
