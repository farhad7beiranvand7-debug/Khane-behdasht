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

  static const _background = Color(0xFFF7F9F6);
  static const _green = Color(0xFF527A18);
  static const _lightGreen = Color(0xFFEAF3DF);
  static const _text = Color(0xFF263238);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    const engine = HealthServiceEngine();
    final services = engine.servicesFor(person);

    final upcoming = services
        .where(
          (service) =>
              service.status == HealthServiceStatus.action ||
              service.status == HealthServiceStatus.upcoming,
        )
        .toList();

    final grouped = <HealthServiceCategory, List<HealthService>>{};

    for (final service in services) {
      if (_shouldHide(service)) continue;

      grouped.putIfAbsent(service.category, () => []).add(service);
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'مراقبت‌های سلامت',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            _PersonInfo(person: person),
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'مراقبت‌های پیش رو',
              ),
              const SizedBox(height: 8),
              ...upcoming
                  .where((service) => !_shouldHide(service))
                  .map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ServiceRow(
                        person: person,
                        service: service,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 20),
            ..._orderedCategories(grouped).map(
              (category) {
                final items = grouped[category]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _CategorySection(
                    title: _categoryTitle(category),
                    count: items.length,
                    children: items
                        .map(
                          (service) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: _ServiceRow(
                              person: person,
                              service: service,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            if (services.isEmpty) const _EmptyServices(),
            const SizedBox(height: 4),
            const Text(
              'زمان و نوع برخی خدمات بر اساس سن، سابقه فرد و دستورالعمل‌های مرکز سلامت تعیین می‌شود.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldHide(HealthService service) {
    if (service.category == HealthServiceCategory.vaccination) {
      return false;
    }

    return false;
  }

  List<HealthServiceCategory> _orderedCategories(
    Map<HealthServiceCategory, List<HealthService>> grouped,
  ) {
    const order = [
      HealthServiceCategory.child,
      HealthServiceCategory.adolescent,
      HealthServiceCategory.youth,
      HealthServiceCategory.elderly,
      HealthServiceCategory.periodicCare,
      HealthServiceCategory.screening,
      HealthServiceCategory.women,
      HealthServiceCategory.pregnancy,
      HealthServiceCategory.mentalHealth,
      HealthServiceCategory.nutrition,
      HealthServiceCategory.oralHealth,
      HealthServiceCategory.vaccination,
    ];

    return order.where(grouped.containsKey).toList();
  }

  String _categoryTitle(HealthServiceCategory category) {
    switch (category) {
      case HealthServiceCategory.child:
        return 'مراقبت‌های کودک';
      case HealthServiceCategory.adolescent:
        return 'مراقبت‌های نوجوان';
      case HealthServiceCategory.youth:
        return 'مراقبت‌های جوان';
      case HealthServiceCategory.elderly:
        return 'سلامت سالمند';
      case HealthServiceCategory.periodicCare:
        return 'مراقبت‌های دوره‌ای';
      case HealthServiceCategory.screening:
        return 'غربالگری و بررسی‌ها';
      case HealthServiceCategory.women:
        return 'سلامت زنان';
      case HealthServiceCategory.pregnancy:
        return 'مراقبت‌های بارداری';
      case HealthServiceCategory.mentalHealth:
        return 'سلامت روان';
      case HealthServiceCategory.nutrition:
        return 'تغذیه و سبک زندگی';
      case HealthServiceCategory.oralHealth:
        return 'دهان و دندان';
      case HealthServiceCategory.vaccination:
        return 'واکسیناسیون';
    }
  }
}

class _PersonInfo extends StatelessWidget {
  const _PersonInfo({
    required this.person,
  });

  final Person person;

  static const _text = Color(0xFF263238);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF3DF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            person.sex == PersonSex.female
                ? Icons.female_rounded
                : Icons.male_rounded,
            color: Color(0xFF527A18),
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.fullName,
                style: const TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تاریخ تولد: ${person.birthDate}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  static const _text = Color(0xFF263238);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$count خدمت',
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ...children,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  static const _green = Color(0xFF527A18);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF263238),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.person,
    required this.service,
  });

  final Person person;
  final HealthService service;

  static const _green = Color(0xFF527A18);
  static const _lightGreen = Color(0xFFEAF3DF);
  static const _text = Color(0xFF263238);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    const engine = HealthServiceEngine();
    final schedule = engine.scheduleFor(person, service);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(service.category),
                  color: _green,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.shortTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(schedule, service.status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: schedule != null ? _green : _muted,
                        fontSize: 11.5,
                        fontWeight: schedule != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF98A2B3),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(
    HealthServiceSchedule? schedule,
    HealthServiceStatus status,
  ) {
    if (schedule != null) {
      return 'موعد: ${schedule.date}';
    }

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

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({
    super.key,
    required this.person,
    required this.service,
  });

  final Person person;
  final HealthService service;

  static const _background = Color(0xFFF7F9F6);
  static const _green = Color(0xFF527A18);
  static const _text = Color(0xFF263238);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    const engine = HealthServiceEngine();
    final schedule = engine.scheduleFor(person, service);

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
          'خدمت سلامت',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Text(
              person.fullName,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              service.title,
              style: const TextStyle(
                color: _text,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (schedule != null)
              _DateCard(
                schedule: schedule,
                isVaccination: isVaccination,
                isPregnancy: isPregnancy,
              )
            else
              _InfoCard(
                message: _noDateMessage(
                  isVaccination: isVaccination,
                  isPregnancy: isPregnancy,
                ),
              ),
            if (service.description.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'درباره خدمت',
                style: TextStyle(
                  color: _text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                service.description,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _noDateMessage({
    required bool isVaccination,
    required bool isPregnancy,
  }) {
    if (isVaccination) {
      return 'برای این فرد در حال حاضر موعد واکسن قابل محاسبه نیست.';
    }

    if (isPregnancy) {
      return 'برای محاسبه موعد مراقبت بارداری، تاریخ شروع بارداری باید ثبت شده باشد.';
    }

    return 'برای این خدمت موعد مشخصی قابل محاسبه نیست.';
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.schedule,
    required this.isVaccination,
    required this.isPregnancy,
  });

  final HealthServiceSchedule schedule;
  final bool isVaccination;
  final bool isPregnancy;

  static const _green = Color(0xFF527A18);
  static const _lightGreen = Color(0xFFEAF3DF);
  static const _text = Color(0xFF263238);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    final type = isVaccination
        ? 'واکسیناسیون برنامه‌ای'
        : isPregnancy
            ? 'مراقبت دوران بارداری'
            : 'خدمت سلامت';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                color: _green,
                size: 21,
              ),
              SizedBox(width: 7),
              Text(
                'موعد انجام',
                style: TextStyle(
                  color: _green,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              schedule.date.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            schedule.title,
            style: const TextStyle(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
          if (schedule.description.trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              schedule.description,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.7,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF667085),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 12.5,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF527A18),
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'در حال حاضر خدمتی برای نمایش وجود ندارد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF344054),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
