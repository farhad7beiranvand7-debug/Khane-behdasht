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

    final actionServices = services
        .where(
          (item) => item.status == HealthServiceStatus.action,
        )
        .toList();

    final categories = <HealthServiceCategory>[
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
        padding: const EdgeInsets.all(16),
        children: [
          _PersonHeader(person: person),

          const SizedBox(height: 20),

          if (actionServices.isNotEmpty)
            _ActionCard(
              services: actionServices,
            ),

          const SizedBox(height: 20),

          Text(
            'خدمات سلامت',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          const Text(
            'بر اساس سن، جنسیت و شرایط ثبت‌شده برای این فرد.',
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
            const CircleAvatar(
              radius: 28,
              child: Icon(
                Icons.person_outline,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.services,
  });

  final List<HealthService> services;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .error,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'الان مهم است',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'این موارد در حال حاضر نیاز به توجه دارند.',
            ),
            const SizedBox(height: 12),
            for (final service in services)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                ),
                title: Text(
                  service.shortTitle,
                ),
                subtitle: Text(
                  service.description,
                ),
              ),
          ],
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
      margin: const EdgeInsets.only(bottom: 12),
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
          '${services.length} مورد',
        ),
        children: [
          for (final service in services)
            ListTile(
              title: Text(
                service.title,
              ),
              subtitle: Text(
                service.description,
              ),
            ),
        ],
      ),
    );
  }

  String _titleFor(
    HealthServiceCategory category,
  ) {
    switch (category) {
      case HealthServiceCategory.periodicCare:
        return 'مراقبت‌های دوره‌ای';

      case HealthServiceCategory.screening:
        return 'بررسی‌ها و غربالگری‌ها';

      case HealthServiceCategory.vaccination:
        return 'واکسیناسیون';

      case HealthServiceCategory.women:
        return 'سلامت زنان';

      case HealthServiceCategory.pregnancy:
        return 'مراقبت بارداری';

      case HealthServiceCategory.mentalHealth:
        return 'سلامت روان';

      case HealthServiceCategory.nutrition:
        return 'تغذیه و فعالیت بدنی';

      case HealthServiceCategory.oralHealth:
        return 'سلامت دهان و دندان';
    }
  }

  IconData _iconFor(
    HealthServiceCategory category,
  ) {
    switch (category) {
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
}
