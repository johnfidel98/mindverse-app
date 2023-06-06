import 'package:flutter/material.dart';
import 'package:mindverse/utils.dart';

class RoamPage extends StatelessWidget {
  const RoamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: const LeadingBack(),
        title: const Text(
          'Roam About',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
