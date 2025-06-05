import 'package:flutter/material.dart';

class BashToolsPage extends StatelessWidget {
  const BashToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          '📘 Esta sección es para: Bash Tools',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
