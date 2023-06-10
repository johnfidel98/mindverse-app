import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.profile}) : super(key: key);
  final UserProfile profile;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SessionController sc = Get.find<SessionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          Image.asset(
            'assets/images/pexels-adrien-olichon-3137056.jpg',
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white70,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20, top: 100, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        AvatarSegment(
                          userProfile: widget.profile,
                          expanded: false,
                          size: 160,
                        ),
                        const SizedBox(height: 30),
                        NamingSegment(
                          owner: widget.profile,
                          size: 30,
                          fontDiff: 10,
                          colAlignment: CrossAxisAlignment.center,
                          vertical: true,
                        ),
                        const SizedBox(height: 50),
                        Text(
                          widget.profile.bio,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Card(
                      color: const Color.fromARGB(255, 248, 110, 100),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              'Danger Zone',
                              style: defaultTextStyle.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Kindly take note that deleting your account (by pressing the button below) is completely irreversible. ',
                              style: defaultTextStyle.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: MVButton(
                                onClick: () {},
                                label: 'Delete Account',
                                paddingH: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 50,
            left: 0,
            child: LeadingBack(),
          )
        ],
      ),
    );
  }
}
