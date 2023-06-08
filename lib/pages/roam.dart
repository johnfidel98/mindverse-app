import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindverse/constants.dart';
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
        title: Text(
          '#RoamAbout',
          style: defaultTextStyle.copyWith(
            color: Colors.black87,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class RoamCard extends StatelessWidget {
  const RoamCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const RoamPage()),
      child: Card(
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 200,
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Lottie.asset(
                'assets/lottie/82445-travelers-walking-using-travelrmap-application.json',
                repeat: true,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.0, -1.0),
                    end: Alignment(0.0, 1.0),
                    colors: [
                      Colors.white10,
                      Colors.white60,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 30,
                  bottom: 6,
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#RoamAbout',
                      style: defaultTextStyle.copyWith(
                        fontSize: 25,
                        height: 1.2,
                        color: htSolid5,
                      ),
                    ),
                    const Text(
                      'Navigate tags of interest and join conversations with respective parties!',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: htSolid3,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
