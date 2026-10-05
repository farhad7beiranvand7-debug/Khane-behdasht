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

/// فقط برای فردی که بارداری برای او ثبت شده است
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
