import 'package:flutter/material.dart';
import 'package:mindverse/utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: const LeadingBack(),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
