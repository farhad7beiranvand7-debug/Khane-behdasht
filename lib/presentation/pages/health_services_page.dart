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

const categories = <HealthServiceCategory>[
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
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
    children: [
      _PersonHeader(person: person),

      const SizedBox(height: 20),

      if (important.isNotEmpty)
        _ImportantCard(services: important),

      const SizedBox(height: 20),

      Text(
        'خدمات مربوط به شما',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        style: TextStyle(fontSize: 12),
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
          _ImportantServiceTile(service: service),
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
child: Icon(_iconFor(service.category)),
),
title: Text(
service.shortTitle,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: Text(service.description),
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
    leading: Icon(_iconFor(category)),
    title: Text(
      _titleFor(category),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text('${services.length} خدمت'),
    children: [
      for (final service in services)
        _ServiceTile(service: service),
    ],
  ),
);

}

String _titleFor(HealthServiceCategory category) {
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
return ListTile(
leading: Icon(_iconFor(service.category)),
title: Text(service.title),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 3),
Text(service.description),
const SizedBox(height: 5),
Text(
_statusText(service.status),
style: TextStyle(
fontSize: 12,
color: Theme.of(context).colorScheme.primary,
fontWeight: FontWeight.bold,
),
),
],
),
);
}
}

String _statusText(HealthServiceStatus status) {
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

IconData _iconFor(HealthServiceCategory category) {
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
