import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers.dart';
import 'package:mindverse/pages/auth.dart';
import 'package:mindverse/pages/home.dart';
import 'package:mindverse/utils.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController nc = TextEditingController();
  final TextEditingController uc = TextEditingController();

  final SessionController session = Get.find<SessionController>();

  bool usernameAvailable = false;
  bool pinging = false;
  bool changing = true;
  String newUsername = '';

  @override
  void dispose() {
    // other dispose methods
    nc.dispose();
    uc.dispose();
    super.dispose();
  }

  void getStarted(String username) => session
      .updateName(nme: nc.text)
      .then((_) => session.setUserDetails().then((loggedIn) {
            if (loggedIn) {
              session.setProfile(uname: username, data: {
                "bio": "Hi there! I'm new here ...",
                "userId": session.userId.value,
                "name": nc.text,
                "lastOnline": DateTime.now().toUtc().toString(),
              }).then((_) => session.setPrefs(newPrefs: {
                    "username": username,
                  }).then((_) {
                    Get.offAll(() => const HomePage());
                    session.setActionStatus(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Welcome to hashTag!",
                              textAlign: TextAlign.center)),
                    );
                  }));
            } else {
              Get.offAll(() => const AuthPage());
              session.setActionStatus(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                  'Kindly log in first!',
                  textAlign: TextAlign.center,
                )),
              );
            }
          }));

  void changedUsername(String username) => setState(() {
        newUsername = username;
        pinging = false;
        changing = true;
      });

  Future<void> pingUsername() async {
    setState(() {
      pinging = true;
      changing = false;
    });
    return session.getProfile(uname: newUsername).then((response) {
      setState(() {
        usernameAvailable = false;
        pinging = false;
      });
    }).catchError((error) {
      if (error.toString().contains('could not be found')) {
        setState(() {
          usernameAvailable = true;
          pinging = false;
        });
      } else {
        pingUsername();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 300,
                ),
              ),
              const Text('Welcome to MindVerse'),
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: MVTextInput(
                  hintText: 'Name',
                  controller: nc,
                  validator: hasCharactersValidator,
                  validationMsg: "Kindly enter your name",
                  prefixIcon: const Icon(
                    Icons.account_circle,
                    color: htSolid2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 15.0,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    MVTextInput(
                      hintText: 'Username',
                      controller: uc,
                      onChanged: changedUsername,
                      prefixIcon: const Icon(
                        Icons.alternate_email,
                        color: htSolid2,
                      ),
                      suffixWidget: InkWell(
                        onTap: () async => await pingUsername(),
                        child: Icon(
                          pinging
                              ? Icons.cloud_sync
                              : changing
                                  ? Icons.published_with_changes
                                  : usernameAvailable
                                      ? Icons.check
                                      : Icons.sync_problem,
                          color: htSolid3,
                        ),
                      ),
                    ),
                    Text(
                      newUsername.isNotEmpty
                          ? changing
                              ? ''
                              : !pinging
                                  ? usernameAvailable
                                      ? "${uc.text} is available ..."
                                      : "@${uc.text} is already taken!"
                                  : "Checking availability ..."
                          : "...",
                      style: TextStyle(
                          fontSize: 16,
                          color: usernameAvailable
                              ? const Color.fromARGB(255, 1, 117, 5)
                              : const Color.fromARGB(255, 163, 11, 0)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: MVButton(
                  onClick: () => uc.text.isNotEmpty
                      ? pingUsername().then((_) {
                          if (usernameAvailable && nc.text.isNotEmpty) {
                            getStarted(newUsername);
                          } else {
                            session.setActionStatus(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Kindly fill in the input values above!')),
                            );
                          }
                        })
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kindly specify username!'),
                          ),
                        ),
                  label: 'Get Started',
                  txtColor: htSolid1,
                  paddingH: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
