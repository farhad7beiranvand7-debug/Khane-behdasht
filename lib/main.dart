import 'package:flutter/material.dart';

import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KhaneBehdashtApp());
}

class KhaneBehdashtApp extends StatelessWidget {
  const KhaneBehdashtApp({
    super.key,
    this.home,
  });

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00695C);

    return MaterialApp(
      title: 'خانه بهداشت پزشک خانواده',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: home ?? const HomePage(),
    );
  }
}
