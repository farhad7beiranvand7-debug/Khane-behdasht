import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره برنامه')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Icon(Icons.health_and_safety_outlined, size: 64),
          SizedBox(height: 16),
          Text(
            'خانه بهداشت پزشک خانواده',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'این برنامه برای ثبت اعضای خانواده و یادآوری زمان مراقبت‌ها و واکسیناسیون طراحی شده است. اطلاعات اصلی برنامه به‌صورت محلی روی گوشی نگهداری می‌شود و برای عملکرد اصلی به اینترنت یا مکان‌یابی نیاز ندارد.',
          ),
          SizedBox(height: 16),
          Text(
            'توجه پزشکی: زمان‌بندی‌های برنامه برای یادآوری و نظم‌دهی هستند. اگر واکسنی انجام نشده، تاریخ آن گذشته یا شرایط فردی خاصی وجود دارد، وضعیت باید بر اساس کارت واکسن و نظر پزشک یا ماما بررسی شود.',
          ),
        ],
      ),
    );
  }
}
