import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/pages/profile.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:appwrite/models.dart' as aw;
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mindverse/components/ad.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/pages/conversation.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class GroupsTab extends StatefulWidget {
  const GroupsTab({Key? key}) : super(key: key);

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  late final PanelController _controllerSlidePanel;

  @override
  void initState() {
    super.initState();

    _controllerSlidePanel = PanelController();

    // get groups where im member
    cc.getGroups(sc: sc);
  }

  void openGroupCreatePanel() => _controllerSlidePanel.open();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => cc.groups.isNotEmpty
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeTitle(
                        title: 'Groups',
                        statsWidget: getGroupsAction(),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: cc.groups.length,
                        itemBuilder: (BuildContext context, int index) {
                          Group g = cc.groups[index];
                          return Column(
                            children: [
                              GroupTile(grp: g),
                              index % 4 == 0
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2),
                                      child: NativeAdvert(),
                                    )
                                  : const SizedBox(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : cc.loadingGroups.value && !cc.firstLoadGroups.value
                ? const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: GeneralLoading(
                      artifacts: 'Groups',
                    ),
                  )
                : EmptyMsg(
                    lottiePath: 'assets/lottie/16952-group-working.json',
                    title: 'Groups',
                    message:
                        'Connect and discuss with several like minded people!',
                    child: getGroupsAction(),
                  )),
        SlidingUpPanel(
          maxHeight: 270,
          minHeight: 0,
          controller: _controllerSlidePanel,
          panel: GroupCreate(
            cancel: () => _controllerSlidePanel.close(),
          ),
        )
      ],
    );
  }

  InterfaceButton getGroupsAction() => InterfaceButton(
        label: 'Create Group',
        icon: Icons.group_add,
        onPressed: openGroupCreatePanel,
      );
}

class GroupCreate extends StatefulWidget {
  const GroupCreate({Key? key, required this.cancel}) : super(key: key);

  final Function() cancel;

  @override
  State<GroupCreate> createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  final TextEditingController gc = TextEditingController();

  bool groupPrivacy = false;
  String groupName = '';

  @override
  void initState() {
    super.initState();

    // get groups where im member
    cc.getGroups(sc: sc);

    // listen to group name changes
    gc.addListener(onGroupNameChanged);
  }

  void onGroupNameChanged() => setState(() => groupName = gc.text);

  void onGroupPrivacyChanged(bool c) => setState(() => groupPrivacy = c);

  void createGroup() {
    sc.createDoc(collectionName: 'groups', data: {
      "sourceId": sc.username.value,
      "name": groupName,
      "isPrivate": groupPrivacy,
      "dstEntities": [sc.username.value],
    }).then((aw.Document gDoc) {
      // clear previous group name
      gc.clear();

      // go back to groups list
      widget.cancel();

      // navigate to group after creation
      Get.to(() => ConversationPage(
            entityId: gDoc.$id,
            isGrp: true,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text('Create Group',
                style: defaultTextStyle.copyWith(fontSize: 20)),
          ),
          MVTextInput(hintText: "Group Name", controller: gc),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Private Group',
                  style: defaultTextStyle.copyWith(fontSize: 18),
                ),
                Switch(value: groupPrivacy, onChanged: onGroupPrivacyChanged),
              ],
            ),
          ),
          Row(
            children: [
              InterfaceButton(
                onPressed: widget.cancel,
                label: 'Cancel',
                size: 3,
                alt: true,
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InterfaceButton(
                    onPressed: createGroup,
                    label: 'Create Group',
                    size: 3,
                    icon: Icons.group_add,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // remove group name listener and active subscriptions
    gc.removeListener(onGroupNameChanged);
    super.dispose();
  }
}

class GroupTile extends StatelessWidget {
  const GroupTile({
    super.key,
    required this.grp,
  });

  final Group grp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ConversationPage(
            entityId: grp.id,
            isGrp: true,
          )),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  grp.logo != null
                      ? ImagePath(
                          bucket: 'group_logos',
                          imageId: grp.logo!,
                          isCircular: true,
                        )
                      : Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                              color: htSolid1, shape: BoxShape.circle),
                          child: const Icon(Icons.group,
                              size: 40, color: htSolid5)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            if (grp.isPrivate)
                              const Padding(
                                padding: EdgeInsets.only(right: 2.0),
                                child: Icon(
                                  Icons.lock,
                                  color: htSolid4,
                                  size: 13,
                                ),
                              ),
                            Text(
                              grp.lastProfile != null ? grp.name : 'New Group',
                              style: const TextStyle(
                                  fontSize: 12, color: htSolid4),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (grp.lastProfile != null)
                              StaticAvatarSegment(
                                  isCircular: true,
                                  size: 18,
                                  path: grp.lastProfile!.avatar.isNotEmpty
                                      ? grp.lastProfile!.avatar
                                      : 'assets/images/user.png'),
                            if (grp.lastProfile != null)
                              const SizedBox(width: 5),
                            grp.lastProfile != null
                                ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 150,
                                    child: Text(
                                      grp.lastMessage,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontStyle: grp.lastProfile != null
                                            ? null
                                            : FontStyle.italic,
                                        fontSize: 18,
                                        color: grp.lastProfile != null
                                            ? htSolid5
                                            : htSolid2,
                                        height: grp.lastProfile != null
                                            ? null
                                            : 1.5,
                                      ),
                                    ))
                                : SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 140,
                                    child: Text(
                                      grp.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: htSolid4,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                          ],
                        ),
                        grp.lastPosted != null
                            ? Text(
                                timeago.format(grp.lastPosted!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: htSolid2,
                                ),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width - 150,
                                child: Text(
                                  grp.lastMessage,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: htSolid2,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ))
                      ],
                    ),
                  )
                ],
              ),
              NumberCircleCount(value: grp.count, fontSize: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupManage extends StatefulWidget {
  const GroupManage({Key? key, this.cancel, required this.grp})
      : super(key: key);

  final Function()? cancel;
  final Group grp;

  @override
  State<GroupManage> createState() => _GroupManageState();
}

class _GroupManageState extends State<GroupManage> with WidgetsBindingObserver {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  bool loadingGroup = true;
  bool loadingSearch = false;
  bool uploadingLogo = false;
  String mode = 'members';
  String? logoId;
  List<UserProfile> members = [];
  List<UserProfile> matches = [];

  final TextEditingController gr = TextEditingController();

  @override
  void initState() {
    super.initState();

    // add listener to note text changes
    gr.addListener(nameSearch);

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => loadMembers());
  }

  _selectLogo(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final XFile? i = await picker.pickImage(source: ImageSource.gallery);

    if (i != null) {
      setState(() {
        uploadingLogo = true;
      });

      // upload group logo
      await sc.uploadFile(
          bucket: 'group_logos',
          f: {'name': i.name, 'path': i.path}).then((aw.File file) async {
        // update details in db
        await sc.updateDoc(
            collectionName: 'groups',
            docId: widget.grp.id,
            data: {'logo': file.$id});

        // update state
        setState(() {
          uploadingLogo = false;
          logoId = file.$id;
        });

        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
              content: Text(
            "Logo successfully uploaded!",
            textAlign: TextAlign.center,
          )),
        );
      });
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
            content: Text(
          "No image was selected!",
          textAlign: TextAlign.center,
        )),
      );
    }
  }

  void nameSearch() async {
    // check for text input
    if (gr.text.isNotEmpty) {
      // change listing mode
      setState(() {
        mode = 'search';
        loadingSearch = true;
      });

      await sc.searchProfile(q: gr.text).then((aw.DocumentList docs) async {
        // process profile matches
        List<UserProfile> newMatches = [];
        for (aw.Document doc in docs.documents) {
          // resolve profile
          UserProfile pm = await sc.getProfile(uname: doc.$id);
          newMatches.add(pm);
        }

        // update state
        setState(() {
          matches = newMatches;
          loadingSearch = false;
        });
      });
    }
  }

  void loadMembers() async {
    // set group logo
    setState(() {
      logoId = widget.grp.logo;
    });

    // get group member profiles
    List<UserProfile> tMembers = [];
    for (String m in widget.grp.members!) {
      tMembers.add(await sc.getProfile(uname: m));
    }

    // update state
    setState(() {
      members = tMembers;
      loadingGroup = false;
    });
  }

  void removeMember(String uname) async {
    List<String> newMembers = widget.grp.members!.cast<String>();
    newMembers.remove(uname);

    // update details
    await sc.updateGroup(
        groupId: widget.grp.id,
        newDetails: {'dstEntities': newMembers}).then((_) {
      // update state
      setState(() {
        loadingGroup = true;
      });

      // reload members
      loadMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Member Removed!", textAlign: TextAlign.center)),
      );
    });
  }

  void addMember(String uname) async {
    List<String> allMembers = widget.grp.members!.cast<String>();

    // check if not in group
    if (!allMembers.contains(uname)) {
      // add member to group
      allMembers.add(uname);
    }

    // update details
    await sc.updateGroup(
        groupId: widget.grp.id,
        newDetails: {'dstEntities': allMembers}).then((_) {
      // update state
      setState(() {
        loadingGroup = true;
      });

      // reload members
      loadMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Member Added!", textAlign: TextAlign.center)),
      );
    });
  }

  void removeGroup() async {
    sc.deleteDoc(collectionName: 'groups', docId: widget.grp.id).then((_) {
      // navigate back home
      Get.offAllNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SlideIndicator(height: 2),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: GestureDetector(
                      onTap: () => _selectLogo(context),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          logoId != null
                              ? ImagePath(
                                  bucket: 'group_logos',
                                  imageId: logoId!,
                                  isCircular: true,
                                  size: 100)
                              : Container(
                                  height: 100,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                      color: htSolid2, shape: BoxShape.circle),
                                  child: const Icon(Icons.group,
                                      size: 70, color: htSolid5),
                                ),
                          Container(
                              height: 100,
                              width: 100,
                              decoration: const BoxDecoration(
                                  color: htTrans3, shape: BoxShape.circle),
                              child: const Icon(Icons.edit,
                                  size: 50, color: htSolid5))
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 15),
                  child: Column(
                    children: [
                      Text(
                          widget.grp.admin == sc.username.value
                              ? 'Manage Group'
                              : 'View Members',
                          style: defaultTextStyle.copyWith(fontSize: 25)),
                      if (widget.grp.admin == sc.username.value)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InterfaceButton(
                              label: 'Delete Group',
                              onPressed: () => showAlertDialog(
                                context: context,
                                title: 'Confirm Group Deletion',
                                msg:
                                    'Are you sure you want to delete the group "${widget.grp.name}"?',
                                onOk: () => removeGroup(),
                              ),
                              icon: Icons.delete,
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                loadingGroup
                    ? const Expanded(
                        child: GeneralLoading(
                          artifacts: 'Members',
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            if (widget.grp.admin == sc.username.value)
                              MVTextInput(
                                hintText: 'New Member',
                                suffixWidget: gr.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          gr.clear();

                                          // reset to group members listing
                                          setState(() {
                                            mode = 'members';
                                          });
                                        },
                                        icon: const Icon(Icons.cancel))
                                    : null,
                                controller: gr,
                                onTappedOutside: () {
                                  if (gr.text.isEmpty) {
                                    // reset to group members listing
                                    setState(() {
                                      mode = 'members';
                                    });
                                  }
                                },
                                prefixIcon: const Icon(Icons.person),
                              ),
                            SizedBox(
                                height: widget.grp.admin == sc.username.value
                                    ? 10
                                    : 0),
                            mode == 'search'
                                ? loadingSearch
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 80.0),
                                        child: GeneralLoading(
                                          artifacts: 'Search',
                                          bgColor: null,
                                        ),
                                      )
                                    : GroupList(
                                        title: 'Search Results',
                                        members: matches,
                                        grp: widget.grp,
                                        action: addMember,
                                      )
                                : GroupList(
                                    title: 'Members',
                                    members: members,
                                    action: removeMember,
                                    grp: widget.grp),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // remove namesearch listener
    gr.removeListener(nameSearch);

    super.dispose();
  }
}

class GroupList extends StatelessWidget {
  const GroupList(
      {Key? key,
      required this.action,
      required this.members,
      required this.grp,
      required this.title})
      : super(key: key);

  final Function(String) action;
  final List<UserProfile> members;
  final String title;
  final Group grp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GroupTitle(title: title),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (BuildContext context, int index) {
            UserProfile p = members[index];
            if (title == 'Members') {
              return GroupMemberTile(
                profile: p,
                group: grp,
                actionFunc: () => showAlertDialog(
                  context: context,
                  title: 'Confirm Member Removal',
                  msg:
                      'Are you sure you want to remove "${p.name}" from the group "${grp.name}"?',
                  onOk: () => action(p.username),
                ),
              );
            } else {
              return GroupMemberTile(
                profile: p,
                group: grp,
                actionName: 'Add',
                actionFunc: () => showAlertDialog(
                  context: context,
                  title: 'Confirm New Member',
                  msg:
                      'Are you sure you want to add "${p.name}" to the group "${grp.name}"?',
                  onOk: () => action(p.username),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class GroupTitle extends StatelessWidget {
  const GroupTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: defaultTextStyle.copyWith(fontSize: 20),
      ),
    );
  }
}

class GroupMemberTile extends StatelessWidget {
  GroupMemberTile({
    super.key,
    required this.profile,
    this.actionFunc,
    this.actionName = 'Remove',
    required this.group,
  });

  final UserProfile profile;
  final Group group;
  final String actionName;
  final Function()? actionFunc;

  final SessionController sc = Get.find<SessionController>();

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
                GestureDetector(
                  onTap: () => Get.to(() => ProfilePage(profile: profile)),
                  child: AvatarSegment(
                    userProfile: profile,
                    size: 60,
                    expanded: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NamingSegment(
                        owner: profile,
                        size: 20,
                        vertical: true,
                        height: 1.2,
                        maxWidth: MediaQuery.of(context).size.width - 250,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 250,
                        child: Text(
                          group.admin == profile.username
                              ? 'Group Admin'
                              : group.members!.contains(profile.username)
                                  ? 'Group Member'
                                  : profile.bio,
                          overflow: TextOverflow.ellipsis,
                          style: defaultTextStyle.copyWith(
                              fontSize: 16, height: 1.5, color: htSolid2),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (group.admin == sc.username.value &&
                sc.username.value != profile.username)
              InterfaceButton(
                  onPressed: actionFunc,
                  label: actionName,
                  icon: actionName == 'Add'
                      ? Icons.person_add
                      : Icons.delete_outline,
                  alt: true),
          ],
        ),
      ),
    );
  }
}
