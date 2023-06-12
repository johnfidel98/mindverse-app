import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get.dart' as get_x;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mindverse/pages/auth.dart';
import 'package:mindverse/pages/conversation.dart';
import 'package:mindverse/pages/home.dart';
import 'package:mindverse/pages/notifications.dart';
import 'package:mindverse/pages/profile.dart';
import 'package:mindverse/pages/roam.dart';
import 'package:mindverse/pages/welcome.dart';
import 'package:mindverse/theme.dart';

void main() {
  // splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ensure portrait orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // init ads
  MobileAds.instance.initialize();

  // init appwrite and start app
  SessionController session = get_x.Get.put(SessionController());

  session.init().then((Account account) async {
    // navigate to auth page by default
    String path = '/auth';

    // try setting id from existing session
    await session.setUserDetails().then((loggedIn) async {
      if (loggedIn) {
        await session.getProfile(uname: session.username.value).then((profile) {
          // set user details
          session.setBio(profile.bio);
          session.setName(profile.name);
        });

        path = '/home';
      }
    });

    // path = '/roam';
    // FlutterNativeSplash.remove();

    // load app
    runApp(
      MyApp(
        startPath: path,
        profile: UserProfile(username: session.username.value),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  final String startPath;
  final UserProfile profile;
  const MyApp({
    super.key,
    required this.startPath,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    // init main app and define routes
    return GetMaterialApp(
      theme: appTheme(),
      initialRoute: startPath,
      getPages: [
        GetPage(name: '/auth', page: () => const AuthPage()),
        GetPage(name: '/welcome', page: () => const WelcomePage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(
          name: '/conversation',
          page: () => ConversationPage(
            entityId: profile.username,
            isGrp: false,
          ),
        ),
        GetPage(name: '/profile', page: () => ProfilePage(profile: profile)),
        GetPage(name: '/notifications', page: () => const NotificationsPage()),
        GetPage(name: '/roam', page: () => const RoamPage()),
      ],
    );
  }
}
