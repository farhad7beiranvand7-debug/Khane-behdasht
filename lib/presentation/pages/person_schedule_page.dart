import 'package:flutter/material.dart';

import '../../domain/models/person.dart';

class PersonSchedulePage extends StatelessWidget {
  const PersonSchedulePage({
    super.key,
    required this.person,
  });

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F6),
        foregroundColor: const Color(0xFF263238),
        elevation: 0,
        title: const Text(
          'مراقبت‌های سلامت',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            person.fullName,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
