import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/verification.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/pages/homeTabs/contacts.dart';
import 'package:mindverse/pages/homeTabs/conversations.dart';
import 'package:mindverse/pages/homeTabs/groups.dart';
import 'package:mindverse/pages/notifications.dart';
import 'package:mindverse/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.put(ChatController());

  late Timer _timerNotifications;
  late Timer _timerGroupsUpdate;
  late Timer _timerConversationsUpdate;
  late Timer _timerOnlinePulse;

  @override
  void initState() {
    super.initState();

    // check notifications
    sc.getNotifications();

    // get personal conversations
    cc.getConversations(sc: sc, username: sc.username.value);

    // update online presence now
    setOnlineNow();

    // update online presence every 60 sec
    _timerOnlinePulse = Timer.periodic(
        const Duration(seconds: 60), (_) async => await setOnlineNow());

    // update conversations
    _timerConversationsUpdate = Timer.periodic(
        const Duration(seconds: 40),
        (_) async =>
            // update conversations
            await cc.getConversations(sc: sc, username: sc.username.value));

    // check notifications after every 10 sec
    _timerNotifications = Timer.periodic(
        const Duration(seconds: 20),
        (_) async =>
            // check notifications
            await sc.getNotifications());

    // setup timer to refresh groups listings every 25 seconds
    _timerGroupsUpdate = Timer.periodic(
        const Duration(seconds: 50),
        (_) async =>
            // update groups where im member
            await cc.getGroups(sc: sc));
  }

  Future setOnlineNow() async => await sc
      .updateProfile(data: {"lastOnline": DateTime.now().toUtc().toString()});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Obx(
        () => Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'MindVerse',
                style: defaultTextStyle.copyWith(color: htSolid5, fontSize: 28),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () => Get.to(() => const NotificationsPage()),
                  icon: Stack(
                    children: [
                      Center(
                        child: Obx(() => Icon(
                              sc.notifications.isNotEmpty
                                  ? Icons.notifications
                                  : Icons.notifications_none,
                              color: htSolid5,
                            )),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Obx(
                          () => NumberCircleCount(
                            value: sc.notifications.length,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 15.0),
                child: AccountDropdownSegment(),
              )
            ],
            backgroundColor: Colors.white,
            titleSpacing: 3,
          ),
          body: !sc.verified.value
              ? const EmailVerificationSegment()
              : const TabBarView(
                  children: [
                    ContactsTab(),
                    ConversationsTab(),
                    GroupsTab(),
                  ],
                ),
          bottomNavigationBar: !sc.verified.value
              ? const SizedBox()
              : Container(
                  color: Colors.white,
                  child: TabBar(
                    labelStyle:
                        defaultTextStyle.copyWith(height: 1.3, fontSize: 15),
                    unselectedLabelStyle:
                        defaultTextStyle.copyWith(height: 1.3, fontSize: 14),
                    labelColor: htSolid5,
                    indicator: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: htSolid4, width: 2),
                      ),
                    ),
                    tabs: const [
                      Tab(
                        text: 'Contacts',
                        icon: Icon(Icons.contacts),
                      ),
                      Tab(
                        text: 'Home',
                        icon: Icon(Icons.home),
                      ),
                      Tab(
                        text: 'Groups',
                        icon: Icon(Icons.groups),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // dispose active services
    if (_timerNotifications.isActive) {
      _timerNotifications.cancel();
    }

    if (_timerConversationsUpdate.isActive) {
      _timerConversationsUpdate.cancel();
    }

    if (_timerOnlinePulse.isActive) {
      _timerOnlinePulse.cancel();
    }

    if (_timerGroupsUpdate.isActive) {
      _timerGroupsUpdate.cancel();
    }
    super.dispose();
  }
}
