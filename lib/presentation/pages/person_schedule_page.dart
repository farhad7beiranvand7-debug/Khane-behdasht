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
              const _SectionTitle(title: 'خدمات مورد نیاز'),
              const SizedBox(height: 10),
              ...important.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ServiceTile(
                    service: service,
                    person: person,
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
              const _SectionTitle(title: 'سایر خدمات'),
              const SizedBox(height: 10),
              ...other.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ServiceTile(
                    service: service,
                    person: person,
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
            if (services.isEmpty) const _EmptyServices(),
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

  static const _background = Color(0xFFF9FBF7);
  static const _text = Color(0xFF344054);
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              person.fullName,
              style: const TextStyle(
                color: _muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.title,
              style: const TextStyle(
                color: _text,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            if (schedule != null)
              _ScheduleCard(
                schedule: schedule,
                isVaccination: isVaccination,
                isPregnancy: isPregnancy,
              )
            else
              _NoDateCard(
                isPregnancy: isPregnancy,
                isVaccination: isVaccination,
              ),
            if (service.description.trim().isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                'توضیحات',
                style: TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.description,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.9,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.isVaccination,
    required this.isPregnancy,
  });

  final HealthServiceSchedule schedule;
  final bool isVaccination;
  final bool isPregnancy;

  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    String serviceType;

    if (isVaccination) {
      serviceType = 'واکسیناسیون برنامه‌ای';
    } else if (isPregnancy) {
      serviceType = 'مراقبت دوران بارداری';
    } else {
      serviceType = 'خدمت سلامت';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EBD9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                color: Color(0xFF527A18),
                size: 23,
              ),
              SizedBox(width: 8),
              Text(
                'موعد انجام',
                style: TextStyle(
                  color: Color(0xFF527A18),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFA6E22E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              schedule.date.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            schedule.title,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            serviceType,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          if (schedule.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
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

class _NoDateCard extends StatelessWidget {
  const _NoDateCard({
    required this.isPregnancy,
    required this.isVaccination,
  });

  final bool isPregnancy;
  final bool isVaccination;

  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    String message;

    if (isPregnancy) {
      message =
          'برای محاسبه موعد مراقبت بارداری، تاریخ شروع بارداری ثبت‌شده لازم است.';
    } else if (isVaccination) {
      message =
          'موعد برنامه‌ای واکسیناسیون برای این فرد در حال حاضر قابل محاسبه نیست.';
    } else {
      message = 'برای این خدمت تاریخ مشخصی قابل محاسبه نیست.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _muted,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _text,
                fontSize: 13,
                height: 1.7,
              ),
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
                const Text(
                  'خدمات سلامت متناسب با سن و شرایط فرد',
                  style: TextStyle(
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
    required this.person,
    required this.onTap,
  });

  final HealthService service;
  final Person person;
  final VoidCallback onTap;

  static const _green = Color(0xFFA6E22E);
  static const _darkGreen = Color(0xFF527A18);
  static const _text = Color(0xFF344054);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    const engine = HealthServiceEngine();
    final schedule = engine.scheduleFor(person, service);

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
                      schedule == null
                          ? _statusText(service.status)
                          : '${schedule.title} • ${schedule.date}',
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
      child: const Column(
        children: [
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
