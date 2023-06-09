import 'package:flutter/material.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeTitle(title: 'Contacts', stats: '20 Total'),
            ContactTile(),
            ContactTile(),
            ContactTile(),
            HomeTitle(
              title: 'Unknown',
              statsWidget: InterfaceButton(
                label: 'Sync Contacts',
                icon: Icons.sync,
                onPressed: () {},
              ),
            ),
            ContactTile(),
            ContactTile(),
            ContactTile(),
            ContactTile(),
            ContactTile(),
            ContactTile(),
          ],
        ),
      ),
    );
  }
}

class ContactListing extends StatelessWidget {
  const ContactListing({Key? key, required this.cancel, this.onDrawer = false})
      : super(key: key);

  final Function() cancel;
  final bool onDrawer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (onDrawer)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4),
            child: const Divider(
              color: htSolid5,
              thickness: 5,
            ),
          ),
      ],
    );
  }
}

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
