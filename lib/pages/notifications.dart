import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/models.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/utils.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SessionController sc = Get.find<SessionController>();

  late StreamSubscription _listenerNotifications;
  bool alertedNotificationBlock = false;

  @override
  void initState() {
    super.initState();

    // get notifications once only as home page is aleady checking every 10s
    sc.getNotifications();

    // listen for notification events
    _listenerNotifications = sc.notifications.listen((data) {
      // check if there are more than 100 notifications
      if (data.length > 100 && !alertedNotificationBlock) {
        // notify user of issue
        showAlertDialog(
            context: context,
            title: 'Notifications Bomb?',
            msg:
                'You\'ll have to dismiss the excess notifications (100+) to be able to view more!',
            footer:
                'N/B: You can use the "Dismiss All" button on the app bar (top right).');
        setState(() {
          alertedNotificationBlock = true;
        });
      }
    });
  }

  Future dismissNotification(int i, MVNotification n) async =>
      await sc.removeNotification(index: i, docId: n.id).then(
            (_) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dismissed "${n.title}"')),
            ),
          );

  void dismissAll() async {
    // dismiss all notifications
    int i = 0;
    for (MVNotification n in sc.notifications) {
      await dismissNotification(i, n);
      i += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: const LeadingBack(),
        titleSpacing: 0,
        title: Text(
          'Notifications',
          style: defaultTextStyle.copyWith(
            color: Colors.black87,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          if (sc.notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: dismissAll,
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
          child: Obx(
            () => sc.notifications.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: sc.notifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      MVNotification n = sc.notifications[index];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) async =>
                            dismissNotification(index, n),
                        child: NotificationTile(
                          body: n.body ?? {},
                          title: n.title ?? '',
                          created: n.created,
                          profile: n.profile,
                        ),
                      );
                    },
                  )
                : const EmptyDone(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // discard active subscriptions and services
    _listenerNotifications.cancel();

    super.dispose();
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.body,
    required this.title,
    required this.created,
    this.profile,
  });

  final Map body;
  final String title;
  final DateTime created;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        child: Row(
          children: [
            profile != null
                ? AvatarSegment(
                    userProfile: profile!,
                    expanded: false,
                    size: 60,
                    isCircular: true,
                  )
                : const Icon(
                    Icons.notification_important,
                    size: 60,
                    color: htSolid5,
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 110,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        color: htSolid5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 110,
                      child: Text(
                        body['msg'],
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.2,
                          color: htSolid5,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    timeago.format(DateTime.parse(created.toString())),
                    style: const TextStyle(
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
