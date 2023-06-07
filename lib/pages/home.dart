import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/pages/conversation.dart';
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
  @override
  void initState() {
    super.initState();

    // remove splash screen
    FlutterNativeSplash.remove();
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
                icon: const Icon(
                  Icons.notifications,
                  color: htSolid5,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 15.0),
              child: AccountDropdownSegment(),
            )
          ],
          backgroundColor: Colors.white,
          titleSpacing: 3,
        ),
        body: const HomeLayout(),
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
}

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        SingleChildScrollView(
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
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
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
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeTitle(
                  title: 'Groups',
                  statsWidget: InterfaceButton(
                    label: 'Start Group',
                    icon: Icons.group_add,
                    onPressed: () {},
                  ),
                ),
                GroupTile(),
                GroupTile(),
                GroupTile(),
                GroupTile(),
                GroupTile(),
                GroupTile(),
                GroupTile(),
                GroupTile(),
                GroupTile(),
              ],
            ),
          ),
        ),
      ],
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
                //fit: BoxFit.cover,
                //width: MediaQuery.of(context).size.width - 20,
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

class HomeTitle extends StatelessWidget {
  const HomeTitle({
    super.key,
    required this.title,
    this.stats,
    this.statsWidget,
  });

  final String title;
  final String? stats;
  final Widget? statsWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: htSolid5, fontSize: 24),
          ),
          statsWidget != null
              ? statsWidget!
              : Text(
                  stats!,
                  style: const TextStyle(color: htSolid5, fontSize: 16),
                ),
        ],
      ),
    );
  }
}

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
              const NumberCircleCount(value: 30),
            ],
          ),
        ),
      ),
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

class GroupTile extends StatelessWidget {
  const GroupTile({
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
                StaticAvatarSegment(
                  size: 60,
                  path: 'assets/images/user.png',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Group Name',
                        style: TextStyle(
                            fontSize: 12, height: 1.2, color: htSolid4),
                      ),
                      Text(
                        'Last Message',
                        style: TextStyle(
                            fontSize: 18, height: 1.2, color: htSolid5),
                      ),
                      Text(
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
            const NumberCircleCount(value: 30),
          ],
        ),
      ),
    );
  }
}

class NumberCircleCount extends StatelessWidget {
  const NumberCircleCount({
    super.key,
    required this.value,
  });

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: htSolid5),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          '$value',
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}