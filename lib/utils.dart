import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/pages/profile.dart';

bool hasCharactersValidator(String? nme) =>
    nme != null ? nme.isNotEmpty && nme.length < 30 : false;

class AppWriteDetails {
  String projectId;
  String host;
  String website;
  String databaseId;

  AppWriteDetails(
      {this.projectId = "",
      this.host = "",
      this.databaseId = "",
      this.website = ""});

  Future loadEnvDetails() async {
    await dotenv.load(fileName: ".env");

    projectId = dotenv.env['PROJECT_ID']!;
    host = dotenv.env['HOST']!;
    databaseId = dotenv.env['DATABASE_ID']!;
    website = dotenv.env['WEBSITE']!;
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

class CloseCircleButton extends StatelessWidget {
  const CloseCircleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: htTrans1,
      shape: const CircleBorder(side: BorderSide(width: 1, color: htSolid4)),
      child: IconButton(
        splashRadius: 50,
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, color: htSolid4),
      ),
    );
  }
}

class StatusBarColorObserver extends StatefulWidget {
  final Widget child;

  const StatusBarColorObserver({super.key, required this.child});

  @override
  State<StatusBarColorObserver> createState() => _StatusBarColorObserverState();
}

class _StatusBarColorObserverState extends State<StatusBarColorObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // allow flexible orientation
    SystemChrome.setPreferredOrientations([]);

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => postInit());
  }

  void postInit() {
    // change status bar color
    updateStatusBarColor();
  }

  @override
  void dispose() {
    // resume strict orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      updateStatusBarColor();
    }
  }

  void updateStatusBarColor() {
    Timer(
        const Duration(milliseconds: 500),
        () => SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle.dark.copyWith(
                statusBarIconBrightness: Brightness.light,
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class LeadingBack extends StatelessWidget {
  // custom back action widget
  const LeadingBack({
    super.key,
    this.leftPadding = 15.0,
  });

  final double? leftPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding!),
      child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: htSolid4,
          )),
    );
  }
}

class LeadingLogo extends StatelessWidget {
  // leading with logo widget
  const LeadingLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        top: 12.0,
        bottom: 12.0,
      ),
      child: Image.asset('assets/images/logo.png', height: 10),
    );
  }
}

class AccountDropdownSegment extends StatelessWidget {
  AccountDropdownSegment({super.key});

  final SessionController session = Get.find<SessionController>();

  void navMenu(
      BuildContext context, SessionController session, MVMenuItem item) {
    if (item == MVMenuItem.logout) {
      session.logout().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully logged out!")),
        );

        // reset all routes to auth
        Get.offAllNamed('/auth');
      });
    } else if (item == MVMenuItem.profile) {
      // navigate to profile
      Get.to(() =>
          ProfilePage(profile: UserProfile(username: session.username.value)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MVMenuItem>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MVMenuItem>>[
        PopupMenuItem<MVMenuItem>(
          value: MVMenuItem.profile,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  "@${session.username}",
                  style: defaultTextStyle.copyWith(
                    fontSize: 12,
                    height: 1.2,
                    color: Colors.black54,
                  ),
                ),
              ),
              Obx(
                () => Text(
                  session.name.value,
                  style: defaultTextStyle.copyWith(
                    fontSize: 16,
                    height: 1.4,
                    color: htSolid5,
                  ),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<MVMenuItem>(
          value: MVMenuItem.logout,
          child: Text(
            'Logout',
            style: defaultTextStyle.copyWith(
              fontSize: 16,
              height: 1.5,
              color: htSolid5,
            ),
          ),
        ),
      ],
      onSelected: (selected) => navMenu(context, session, selected),
      child: AvatarSegment(
        userProfile: UserProfile(
          username: session.username.value,
          avatar: session.image.value,
        ),
        expanded: false,
        isCircular: true,
        size: 35,
      ),
    );
  }
}

void releaseFocus({required BuildContext context, Function? onTappedOutside}) {
  // release input widget from focus
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  onTappedOutside != null ? onTappedOutside() : null;
}
