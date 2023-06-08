import 'package:flutter/material.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/models.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+234 54546 65656',
                        style: TextStyle(
                            fontSize: 12, height: 1.2, color: htSolid4),
                      ),
                      Text(
                        'Jack Burrows',
                        style: TextStyle(
                            fontSize: 18, height: 1.4, color: htSolid5),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const InterfaceButton(label: 'Invite', icon: Icons.add, alt: true),
          ],
        ),
      ),
    );
  }
}
