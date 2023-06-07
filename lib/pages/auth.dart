import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers.dart';
import 'package:mindverse/pages/home.dart';
import 'package:mindverse/pages/welcome.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SessionController session = Get.find<SessionController>();
  final TextEditingController ec = TextEditingController();
  final TextEditingController pc = TextEditingController();
  final TextEditingController pcc = TextEditingController();

  String mode = 'signin';

  @override
  void initState() {
    super.initState();

    // remove splash
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    // other dispose methods
    ec.dispose();
    pc.dispose();
    pcc.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);

  bool isSimilarPasswords(String cp) => pc.text == cp;

  void signIn() async {
    // check for validation errors
    if (isValidEmail(ec.text) && pc.text.isNotEmpty) {
      session
          .login(email: ec.text, password: pc.text)
          .then((signInSession) async {
        // update user details
        await session.setUserDetails().then((loggedIn) =>
            session.getProfile(uname: session.username.value).then((profile) {
              // set user details
              session.setBio(profile.bio);
              session.setName(profile.name);

              Get.offAll(() => const HomePage());
              session.setActionStatus(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                  'Welcome back!',
                  textAlign: TextAlign.center,
                )),
              );
            }));
      }).catchError((error) {
        session.setActionStatus(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      });
    } else {
      session.setActionStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly enter a valid email address')),
      );
    }

    if (pc.text.isEmpty) {
      session.setActionStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly enter your password')),
      );
    }
  }

  void signUp() async {
    // check for validation errors
    if (isValidEmail(ec.text) && pc.text == pcc.text) {
      session
          .register(email: ec.text, password: pc.text)
          .then(
            (_) async =>
                session.login(email: ec.text, password: pc.text).then((_) {
              Get.to(() => const WelcomePage());
              session.setActionStatus(true);
            }),
          )
          .catchError((error) {
        session.setActionStatus(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      });
    } else {
      session.setActionStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly enter a valid email address')),
      );
    }

    if (pc.text.isEmpty) {
      session.setActionStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly enter your password')),
      );
    } else if (pc.text != pcc.text) {
      session.setActionStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords don\'t match!')),
      );
    }
  }

  void resetAccount() {
    if (isValidEmail(ec.text)) {
      session.reset(email: ec.text).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset request sent!')),
        );
        setState(() {
          mode = 'signin';
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly enter a valid email address')),
      );
    }
    session.setActionStatus(true);
  }

  void resetAction() => setState(() {
        mode = 'reset';
      });

  void mainAction() => setState(() {
        if (mode != 'reset') {
          if (mode == 'signup') {
            mode = 'signin';
          } else {
            mode = 'signup';
          }
        } else {
          mode = 'signin';
        }
      });

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: KeyboardVisibilityBuilder(
            builder: (context, keyboardVisible) {
              return Stack(
                children: [
                  Image.asset(
                    'assets/images/pexels-adrien-olichon-3137056.jpg',
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.white24,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: AuthInput(
                        mainAction: mainAction,
                        ec: ec,
                        pc: pc,
                        pcc: pcc,
                        signIn: signIn,
                        signUp: signUp,
                        keyboardVisible: keyboardVisible,
                        mode: mode,
                        isValidEmail: isValidEmail,
                        isSimilarPasswords: isSimilarPasswords,
                        resetAccount: resetAccount,
                        resetAction: resetAction,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthInput extends StatefulWidget {
  final bool keyboardVisible;
  final String mode;
  final TextEditingController ec;
  final TextEditingController pc;
  final TextEditingController pcc;
  final Function isValidEmail;
  final Function isSimilarPasswords;
  final Function signIn;
  final Function signUp;
  final Function resetAccount;
  final Function resetAction;
  final Function mainAction;

  const AuthInput(
      {Key? key,
      required this.keyboardVisible,
      required this.mode,
      required this.ec,
      required this.pc,
      required this.pcc,
      required this.isValidEmail,
      required this.isSimilarPasswords,
      required this.signIn,
      required this.signUp,
      required this.resetAccount,
      required this.resetAction,
      required this.mainAction})
      : super(key: key);

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _animationActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.keyboardVisible && widget.mode != 'reset' ? 0 : 10,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: SizedBox(
            height: widget.keyboardVisible
                ? widget.mode == 'signin'
                    ? 80
                    : 0
                : 200,
            child: Image.asset(
              'assets/images/logo.png',
              height: 100,
            ),
          ),
        ),
        widget.mode == 'reset' && widget.keyboardVisible
            ? const Icon(
                Icons.account_box,
                size: 70,
              )
            : const SizedBox(),
        SizedBox(
          height: widget.keyboardVisible && widget.mode != 'reset' ? 10 : 30,
        ),
        AnimatedContainer(
          height: widget.mode == 'signin'
              ? widget.keyboardVisible
                  ? 350
                  : 380
              : widget.mode == 'signup'
                  ? widget.keyboardVisible
                      ? 400
                      : 420
                  : 250,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
          onEnd: () => setState(() {
            _animationActive = false;
          }),
          decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius:
                  BorderRadius.all(Radius.circular(defaultBorderRadius))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.mode == 'reset'
                    ? "Reset your account credentials!"
                    : widget.mode == 'signin'
                        ? "Welcome back, you've been missed!"
                        : "Hmmm, nice of you to join us!",
                style: const TextStyle(
                  fontSize: 18,
                  color: htSolid5,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: MVTextInput(
                        hintText: "Email Address",
                        validator: widget.isValidEmail,
                        validationMsg: "Kindly enter a valid email address!",
                        inputType: TextInputType.emailAddress,
                        controller: widget.ec,
                        prefixIcon: const Icon(
                          Icons.email,
                          color: htSolid2,
                        ),
                      ),
                    ),
                    widget.mode != 'reset'
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    widget.mode == 'signup'
                                        ? Icons.security
                                        : Icons.key,
                                    color: htSolid4,
                                    size: widget.mode == 'signup' ? 65 : 55,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MVTextInput(
                                        hintText: "Password",
                                        obscureText: true,
                                        padding: EdgeInsets.only(
                                            bottom: widget.mode == 'signup'
                                                ? 10
                                                : 0),
                                        controller: widget.pc,
                                        showLabel: false,
                                      ),
                                      widget.mode == 'signup'
                                          ? MVTextInput(
                                              hintText: "Confirm Password",
                                              validationMsg:
                                                  "Passwords doesn't match!",
                                              validator:
                                                  widget.isSimilarPasswords,
                                              obscureText: true,
                                              controller: widget.pcc,
                                              showLabel: false,
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    widget.mode != 'reset'
                        ? const Divider(
                            thickness: 0.5,
                            color: Colors.black,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.mode != 'reset'
                        ? GestureDetector(
                            onTap: () => widget.resetAction(),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.overpass(
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              SizedBox(
                height: _animationActive ? 0 : 10,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: _animationActive ? 30 : 55,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: widget.mode != 'reset'
                    ? widget.mode == 'signup'
                        ? MVButton(
                            onClick: () => widget.signUp(),
                            txtColor: htSolid1,
                            label: 'Register Account',
                            paddingH: 0,
                          )
                        : MVButton(
                            onClick: () => widget.signIn(),
                            txtColor: htSolid1,
                            label: 'Sign In',
                            paddingH: 0,
                          )
                    : MVButton(
                        onClick: () => widget.resetAccount(),
                        txtColor: htSolid1,
                        label: 'Reset Password',
                        paddingH: 0,
                      ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _animationActive = true;
                  });
                  widget.mainAction();
                },
                child: Text(
                  widget.mode != 'reset'
                      ? widget.mode == 'signup'
                          ? 'Already Have An Account!'
                          : 'Register Account?'
                      : 'Login To Account',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
