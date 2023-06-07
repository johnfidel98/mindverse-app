import 'package:flutter/material.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/utils.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: const LeadingBack(),
        titleSpacing: 0,
        title: Text(
          'Notifications',
          style: defaultTextStyle.copyWith(color: Colors.black87, fontSize: 23),
        ),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.clear_all,
                color: htSolid5,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        child: Row(
          children: [
            const Icon(
              Icons.account_circle,
              size: 70,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'message title',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.2,
                      color: htSolid5,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 120,
                    child: const Text(
                      'Last Message Last Message Last Message Last Message Last Message Last Message ',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        color: htSolid5,
                      ),
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
      ),
    );
  }
}
