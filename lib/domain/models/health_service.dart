enum HealthServiceCategory {
  periodicCare,
  screening,
  vaccination,
  women,
  pregnancy,
  mentalHealth,
  nutrition,
  oralHealth,
}

enum HealthServiceStatus {
  action,
  upcoming,
  completed,
  information,
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
  });

  final String id;

  /// نام ساده و قابل نمایش برای مردم
  final String title;

  /// عنوان کوتاه برای کارت‌ها
  final String shortTitle;

  /// توضیح ساده
  final String description;

  final HealthServiceCategory category;
  final HealthServiceStatus status;

  final int? ageMin;
  final int? ageMax;

  final bool femaleOnly;
  final bool maleOnly;
  final bool requiresPregnancy;

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
