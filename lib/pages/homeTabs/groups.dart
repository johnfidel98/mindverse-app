import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:appwrite/models.dart' as aw;
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
                  const Icon(Icons.group, size: 60),
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
                                ? Text(
                                    grp.lastMessage,
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
                                            : 1.5),
                                  )
                                : Text(
                                    grp.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: htSolid4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                            : Text(
                                grp.lastMessage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: htSolid2,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
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
