import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/text.dart';
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

class _ProfilePageState extends State<ProfilePage> {
  final SessionController sc = Get.find<SessionController>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
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
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20, top: 100, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                              if (widget.profile.username == sc.username.value)
                                Container(
                                  height: 160,
                                  width: 160,
                                  color: htTrans3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                        const SizedBox(height: 30),
                        NamingSegment(
                          owner: widget.profile,
                          size: 30,
                          fontDiff: 10,
                          colAlignment: CrossAxisAlignment.center,
                          vertical: true,
                        ),
                        const SizedBox(height: 50),
                        Text(
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
}
