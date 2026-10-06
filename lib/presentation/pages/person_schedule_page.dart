import 'package:flutter/material.dart';

import '../../core/health/health_service_engine.dart';
import '../../domain/models/health_service.dart';
import '../../domain/models/person.dart';

class PersonSchedulePage extends StatelessWidget {
  const PersonSchedulePage({
    super.key,
    required this.person,
  });

  final Person person;

  static const _background = Color(0xFFF9FBF7);
  static const _text = Color(0xFF344054);

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

    final other = services
        .where(
          (service) =>
              service.status != HealthServiceStatus.action &&
              service.status != HealthServiceStatus.upcoming,
        )
        .toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: Text(
          person.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _PersonHeader(person: person),
            const SizedBox(height: 22),

            if (important.isNotEmpty) ...[
              const _SectionTitle(
                title: 'خدمات مورد نیاز',
              ),
              const SizedBox(height: 10),

              ...important.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ServiceTile(
                    service: service,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailPage(
                            person: person,
                            service: service,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            if (other.isNotEmpty) ...[
              const SizedBox(height: 12),
              const _SectionTitle(
                title: 'سایر خدمات',
              ),
              const SizedBox(height: 10),

              ...other.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ServiceTile(
                    service: service,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailPage(
                            person: person,
                            service: service,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            if (services.isEmpty)
              const _EmptyServices(),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({
    super.key,
    required this.person,
    required this.service,
  });

  final Person person;
  final HealthService service;

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _background = Color(0xFFF9FBF7);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    final isVaccination =
        service.category == HealthServiceCategory.vaccination;

    final isPregnancy =
        service.category == HealthServiceCategory.pregnancy ||
        service.requiresPregnancy;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'جزئیات خدمت',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _iconFor(service.category),
                    color: _darkGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  service.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  person.fullName,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                _InfoRow(
                  icon: Icons.event_available_outlined,
                  title: 'موعد انجام',
                  value: _serviceDate(service, person),
                ),

                if (isVaccination) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.vaccines_outlined,
                    title: 'نوع خدمت',
                    value: 'واکسیناسیون',
                  ),
                ],

                if (isPregnancy) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.pregnant_woman_outlined,
                    title: 'مراقبت',
                    value: 'مراقبت دوران بارداری',
                  ),
                ],

                const SizedBox(height: 20),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAECF0),
                ),

                const SizedBox(height: 18),

                Text(
                  service.description,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _serviceDate(
    HealthService service,
    Person person,
  ) {
    if (service.category == HealthServiceCategory.vaccination) {
      return 'بر اساس سن و برنامه واکسیناسیون';
    }

    if (service.category == HealthServiceCategory.pregnancy ||
        service.requiresPregnancy) {
      return 'بر اساس زمان شروع بارداری';
    }

    return 'بر اساس برنامه مراقبت دوره‌ای';
  }

  IconData _iconFor(HealthServiceCategory category) {
    switch (category) {
      case HealthServiceCategory.vaccination:
        return Icons.vaccines_outlined;
      case HealthServiceCategory.pregnancy:
        return Icons.pregnant_woman_outlined;
      case HealthServiceCategory.women:
        return Icons.female_outlined;
      case HealthServiceCategory.child:
        return Icons.child_care_outlined;
      case HealthServiceCategory.adolescent:
        return Icons.school_outlined;
      case HealthServiceCategory.youth:
        return Icons.person_outline_rounded;
      case HealthServiceCategory.elderly:
        return Icons.elderly_outlined;
      case HealthServiceCategory.oralHealth:
        return Icons.health_and_safety_outlined;
      case HealthServiceCategory.nutrition:
        return Icons.restaurant_outlined;
      case HealthServiceCategory.mentalHealth:
        return Icons.psychology_outlined;
      case HealthServiceCategory.screening:
        return Icons.search_outlined;
      case HealthServiceCategory.periodicCare:
        return Icons.health_and_safety_outlined;
    }
  }
}

class _PersonHeader extends StatelessWidget {
  const _PersonHeader({
    required this.person,
  });

  final Person person;

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              person.sex == PersonSex.female
                  ? Icons.female_rounded
                  : Icons.male_rounded,
              color: _darkGreen,
              size: 30,
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
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'خدمات سلامت متناسب با سن و شرایط فرد',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.onTap,
  });

  final HealthService service;
  final VoidCallback onTap;

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconFor(service.category),
                  color: _darkGreen,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.shortTitle,
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _statusText(service.status),
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
    );
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
      case HealthServiceCategory.vaccination:
        return Icons.vaccines_outlined;
      case HealthServiceCategory.pregnancy:
        return Icons.pregnant_woman_outlined;
      case HealthServiceCategory.women:
        return Icons.female_outlined;
      case HealthServiceCategory.child:
        return Icons.child_care_outlined;
      case HealthServiceCategory.adolescent:
        return Icons.school_outlined;
      case HealthServiceCategory.youth:
        return Icons.person_outline_rounded;
      case HealthServiceCategory.elderly:
        return Icons.elderly_outlined;
      case HealthServiceCategory.oralHealth:
        return Icons.health_and_safety_outlined;
      case HealthServiceCategory.nutrition:
        return Icons.restaurant_outlined;
      case HealthServiceCategory.mentalHealth:
        return Icons.psychology_outlined;
      case HealthServiceCategory.screening:
        return Icons.search_outlined;
      case HealthServiceCategory.periodicCare:
        return Icons.health_and_safety_outlined;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: _darkGreen,
          size: 21,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.check_circle_outline_rounded,
            color: _darkGreen,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'در حال حاضر خدمتی برای نمایش وجود ندارد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
