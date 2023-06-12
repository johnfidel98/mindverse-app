import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';
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

class GeneralLoading extends StatelessWidget {
  // app loading progress ring
  const GeneralLoading({
    super.key,
    this.artifacts = '...',
    this.message,
    this.bgColor = Colors.white54,
  });

  final String? artifacts;
  final String? message;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  color: htSolid5,
                  strokeWidth: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Loading $artifacts',
                  style: defaultTextStyle.copyWith(
                    fontSize: 24,
                    color: htSolid5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    '$message',
                    style: defaultTextStyle.copyWith(
                      fontSize: 20,
                      color: htSolid4,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class NumberCircleCount extends StatelessWidget {
  const NumberCircleCount({
    super.key,
    required this.value,
    this.fontSize = 15,
  });

  final int value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return value == 0
        ? const SizedBox()
        : Container(
            decoration: const BoxDecoration(
              color: htSolid4,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                value > 10 ? '10+' : '$value',
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
            ),
          );
  }
}

class EmptyDone extends StatelessWidget {
  const EmptyDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/104297-completed-icon.json',
            repeat: false,
          ),
          const SizedBox(height: 40),
          Text(
            'All Caught Up',
            style: defaultTextStyle.copyWith(fontSize: 30),
          ),
        ],
      ),
    );
  }
}

class EmptyMsg extends StatelessWidget {
  const EmptyMsg({
    super.key,
    this.lottiePath,
    required this.title,
    this.message,
    this.child,
  });

  final String? lottiePath;
  final String title;
  final String? message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // height: MediaQuery.of(context).size.height - 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottiePath != null)
            Lottie.asset(
              lottiePath!,
              repeat: true,
              width: MediaQuery.of(context).size.width - 80,
            ),
          const SizedBox(height: 40),
          Text(
            title,
            style: defaultTextStyle.copyWith(fontSize: 26),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                message!,
                style: defaultTextStyle.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.all(5), child: child),
            ],
          ),
        ],
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

class SlideIndicator extends StatelessWidget {
  const SlideIndicator({
    super.key,
    this.height = 5,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 4),
      child: Divider(
        color: htSolid5,
        thickness: height,
      ),
    );
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

class ImagePath extends StatefulWidget {
  const ImagePath({
    super.key,
    required this.bucket,
    required this.imageId,
    this.size = 60,
    this.isCircular = false,
  });

  final String bucket;
  final String imageId;
  final double size;
  final bool isCircular;

  @override
  State<ImagePath> createState() => _ImagePathState();
}

class _ImagePathState extends State<ImagePath> {
  final SessionController sc = Get.find<SessionController>();

  late Storage _storage;
  late Map _storages;

  @override
  void initState() {
    super.initState();

    // get storage
    _storage = sc.getStorage();
    _storages = sc.getStorages();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _storage.getFileView(
        bucketId: _storages[widget.bucket],
        fileId: widget.imageId,
      ),
      builder: (context, snapshot) {
        return snapshot.hasData && snapshot.data != null
            ? Container(
                clipBehavior: Clip.antiAlias,
                height: widget.size,
                width: widget.size,
                decoration: BoxDecoration(
                    color: htSolid2,
                    shape: widget.isCircular
                        ? BoxShape.circle
                        : BoxShape.rectangle),
                child: Image.memory(
                  snapshot.data!,
                  height: widget.size,
                  fit: BoxFit.cover,
                ))
            : SizedBox(
                height: widget.size,
                width: widget.size,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }
}

class AccountDropdownSegment extends StatelessWidget {
  AccountDropdownSegment({super.key});

  final SessionController session = Get.find<SessionController>();

  void navMenu(
      BuildContext context, SessionController session, MVMenuItem item) async {
    if (item == MVMenuItem.logout) {
      session.logout().then((_) {
        // notify user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully logged out!")),
        );

        // reset all routes to auth
        Get.offAllNamed('/auth');
      });
    } else if (item == MVMenuItem.profile) {
      // navigate to my profile
      UserProfile myProfile =
          await session.getProfile(uname: session.username.value);

      Get.to(() => ProfilePage(profile: myProfile));
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
      child: Obx(() => AvatarSegment(
            userProfile: UserProfile(
              username: session.username.value,
              avatar: session.image.value,
            ),
            expanded: false,
            isCircular: true,
            size: 35,
          )),
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

void showAlertDialog(
    {required BuildContext context,
    String? title = 'Important',
    String? msg,
    Widget? msgWidget,
    String? footer,
    Function()? onOk}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title == null
            ? const SizedBox()
            : Text(
                title,
                style: defaultTextStyle.copyWith(fontSize: 24),
              ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msgWidget != null) msgWidget,
            if (msg != null)
              Text(
                msg,
                style: defaultTextStyle.copyWith(fontSize: 16),
              ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  footer,
                  style: defaultTextStyle.copyWith(fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          // add buttons to the alert prompt
          TextButton(
            style: const ButtonStyle(
                side: MaterialStatePropertyAll(BorderSide(color: htTrans1))),
            child: Text(
              'Cancel',
              style: defaultTextStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(htTrans1)),
            child: Text(
              'Ok',
              style: defaultTextStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // perform any actions you want when the user taps OK
              Navigator.of(context).pop();

              if (onOk != null) {
                // execute ok task
                onOk();
              }
            },
          ),
        ],
      );
    },
  );
}
