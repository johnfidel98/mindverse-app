import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/pages/conversation.dart';
import 'package:mindverse/utils.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
          () => ConversationPage(owner: UserProfile(username: 'maineM'))),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AvatarSegment(
                    userProfile: UserProfile(username: 'unknown'),
                    size: 60,
                    expanded: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NamingSegment(
                          owner: UserProfile(username: 'unknown'),
                          size: 15,
                          height: 1.3,
                          fontDiff: 4,
                        ),
                        const Text(
                          'Last Message',
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            color: htSolid5,
                          ),
                        ),
                        const Text(
                          '2m ago',
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.4,
                            color: htSolid2,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              NumberCircleCount(value: 30),
            ],
          ),
        ),
      ),
    );
  }
}
