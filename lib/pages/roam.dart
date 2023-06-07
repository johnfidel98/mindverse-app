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
        titleSpacing: 0,
        title: const Text(
          '#RoamAbout',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
