import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.profile}) : super(key: key);
  final UserProfile profile;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  final SessionController sc = Get.find<SessionController>();
  final TextEditingController ec = TextEditingController();

  UserProfile profile = UserProfile(username: unknownBastard);
  bool loadingProfile = true;
  String bio = '';

  @override
  void initState() {
    super.initState();

    ec.addListener(_saveBio);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => postInit());
  }

  Future postInit() async {
    // update profile
    UserProfile p = await sc.getProfile(
      uname: widget.profile.username,
      newDetails: true,
    );
    setState(() {
      profile = p;
      loadingProfile = false;
    });

    // set loaded bio on load page
    ec.text = p.bio;
  }

  _selectAvatar(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final XFile? i = await picker.pickImage(source: ImageSource.gallery);

    String msg = '';
    if (i != null) {
      // upload group logo
      await sc.uploadFile(
          bucket: 'profile_avatars',
          f: {'name': i.name, 'path': i.path}).then((aw.File file) async {
        // update details in db
        await sc.updateDoc(
            collectionName: 'profiles',
            docId: widget.profile.username,
            data: {'avatar': file.$id});

        // update state avatar
        sc.setImage(file.$id);

        msg = "Avatar successfully uploaded!";
      });
    } else {
      msg = "No image was selected!";
    }

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.center)),
    );
  }

  _saveBio() => setState(() => bio = ec.text);

  _setBio() => sc.updateDoc(
          collectionName: 'profiles',
          docId: sc.username.value,
          data: {'bio': bio}).then((_) async {
        sc.setBio(bio);

        // notify user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Updated Bio', textAlign: TextAlign.center)),
        );

        // reload profile
        await postInit();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: loadingProfile
          ? const GeneralLoading(
              artifacts: 'Profile',
            )
          : Stack(
              children: [
                Image.asset(
                  'assets/images/pexels-adrien-olichon-3137056.jpg',
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white70,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: widget.profile.username == sc.username.value
                                ? () => _selectAvatar(context)
                                : () {},
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                AvatarSegment(
                                  userProfile: widget.profile,
                                  expanded: false,
                                  size: 160,
                                ),
                                if (widget.profile.username ==
                                    sc.username.value)
                                  Container(
                                    height: 160,
                                    width: 160,
                                    color: htTrans3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.edit,
                                          color: htSolid1,
                                          size: 40,
                                        ),
                                        Text(
                                          'Change Avatar',
                                          style: defaultTextStyle.copyWith(
                                            fontSize: 18,
                                            color: htSolid1,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: NamingSegment(
                                  owner: widget.profile,
                                  size: 30,
                                  fontDiff: 10,
                                  colAlignment: CrossAxisAlignment.center,
                                  vertical: true,
                                ),
                              ),
                              widget.profile.username == sc.username.value
                                  ? Column(
                                      children: [
                                        MVTextInput(
                                          hintText: 'Bio',
                                          controller: ec,
                                          maxLines: 3,
                                          labelFontSize: 18,
                                          txtHeight: 1.5,
                                          paddingV: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (ec.text != profile.bio)
                                              InterfaceButton(
                                                label: 'Save Changes',
                                                onPressed: _setBio,
                                                size: 2,
                                              ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Text(
                                      widget.profile.bio,
                                      textAlign: TextAlign.center,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 50,
                  left: 0,
                  child: LeadingBack(),
                )
              ],
            ),
    );
  }

  @override
  void dispose() {
    // cleanup
    ec.removeListener(_saveBio);

    super.dispose();
  }
}
