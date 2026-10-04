import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const DiagnosticApp(),
  );
}

class DiagnosticApp extends StatelessWidget {
  const DiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'خانه بهداشت پزشک خانواده',
      home: const DiagnosticHomePage(),
    );
  }
}

class DiagnosticHomePage extends StatelessWidget {
  const DiagnosticHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'خانه بهداشت پزشک خانواده',
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 80,
              ),
              SizedBox(height: 24),
              Text(
                'خانه بهداشت پزشک خانواده',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'برنامه با موفقیت اجرا شد.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
