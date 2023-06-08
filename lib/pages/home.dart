import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers.dart';
import 'package:mindverse/pages/homeTabs/contacts.dart';
import 'package:mindverse/pages/homeTabs/conversations.dart';
import 'package:mindverse/pages/homeTabs/groups.dart';
import 'package:mindverse/pages/notifications.dart';
import 'package:mindverse/pages/roam.dart';
import 'package:mindverse/pages/search.dart';
import 'package:mindverse/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  late Timer _timerNotifications;
  late Timer _timerGroupsUpdate;

  @override
  void initState() {
    super.initState();

    // remove splash screen
    FlutterNativeSplash.remove();

    // check notifications
    sc.getNotifications();

    // check notifications after every 10 sec
    _timerNotifications = Timer.periodic(
        const Duration(seconds: 10),
        (_) async =>
            // check notifications
            await sc.getNotifications());

    // setup timer to refresh groups listings every 25 seconds
    _timerGroupsUpdate = Timer.periodic(
        const Duration(seconds: 25),
        (_) async =>
            // get groups where im member
            await sc.getGroups(chatController: cc));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
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
                onPressed: () => Get.to(() => const SearchPage()),
                icon: const Icon(
                  Icons.search,
                  color: htSolid5,
                )),
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
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
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
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoamCard(),
                    HomeTitle(
                      title: 'Conversations',
                      statsWidget: InterfaceButton(
                        label: 'Start',
                        icon: Icons.add,
                        onPressed: () {},
                      ),
                    ),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                    ConversationTile(),
                  ],
                ),
              ),
            ),
            const HomeGroupsTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: TabBar(
            labelStyle: defaultTextStyle.copyWith(height: 1.3, fontSize: 15),
            unselectedLabelStyle:
                defaultTextStyle.copyWith(height: 1.3, fontSize: 14),
            labelColor: htSolid5,
            indicator: const BoxDecoration(
              border: Border(
                top: BorderSide(color: htSolid4, width: 1),
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
    );
  }

  @override
  void dispose() {
    // dispose active services
    if (_timerNotifications.isActive) {
      _timerNotifications.cancel();
    }

    if (_timerGroupsUpdate.isActive) {
      _timerGroupsUpdate.cancel();
    }
    super.dispose();
  }
}
