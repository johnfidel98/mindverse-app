import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';

class EmailVerificationSegment extends StatefulWidget {
  const EmailVerificationSegment({
    super.key,
  });

  @override
  State<EmailVerificationSegment> createState() =>
      _EmailVerificationSegmentState();
}

class _EmailVerificationSegmentState extends State<EmailVerificationSegment> {
  final SessionController session = Get.find<SessionController>();
  late Timer timer;
  bool sentEmail = false;
  bool isAdult = false;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {});
    super.initState();
  }

  void cancelTimer() {
    if (timer.isActive) {
      timer.cancel();
    }
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle =
        GoogleFonts.overpass(textStyle: const TextStyle(fontSize: 18));
    TextStyle descriptionStyle = GoogleFonts.overpass(
        textStyle: const TextStyle(fontSize: 14, height: 1.4));
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.mail,
                    size: 100,
                    color: htSolid5,
                  ),
                  if (sentEmail)
                    const SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: htSolid5,
                        ))
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Hi, ${session.name}',
                  style: defaultTextStyle.copyWith(fontSize: 30),
                ),
                Text(
                  'Send verification request to my email (${session.email}).',
                  textAlign: TextAlign.center,
                  style:
                      defaultTextStyle.copyWith(fontSize: 18, color: htSolid3),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'I\'m an adult!',
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    'I am 18 and above or of legal age in my country!',
                    style: descriptionStyle,
                  ),
                  trailing: Switch(
                      value: isAdult,
                      onChanged: (adult) => setState(() {
                            isAdult = adult;
                          })),
                  minVerticalPadding: 20,
                ),
                const SizedBox(height: 10),
                InterfaceButton(
                    size: 3,
                    bgColor: sentEmail || !isAdult ? Colors.grey : htSolid4,
                    onPressed: sentEmail || !isAdult
                        ? () {}
                        : () => session.sendVerification().then((_) {
                              setState(() {
                                sentEmail = true;
                              });
                              cancelTimer();
                              timer = Timer.periodic(
                                  const Duration(seconds: 10), (_) async {
                                // check verified
                                await session.setUserDetails();
                              });
                            }),
                    label: isAdult
                        ? sentEmail
                            ? "Request Sent"
                            : "Send Verification Request"
                        : "Adults Only!"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
