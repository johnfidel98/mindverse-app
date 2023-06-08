import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class HomeGroupsTab extends StatefulWidget {
  const HomeGroupsTab({Key? key}) : super(key: key);

  @override
  State<HomeGroupsTab> createState() => _HomeGroupsTabState();
}

class _HomeGroupsTabState extends State<HomeGroupsTab> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  final TextEditingController gc = TextEditingController();

  String groupName = '';
  bool createGroupEnabled = true;

  @override
  void initState() {
    super.initState();

    // get groups where im member
    sc.getGroups(chatController: cc);

    // listen to group name changes
    gc.addListener(onGroupNameChanged);
  }

  void onGroupNameChanged() => setState(() {
        groupName = gc.text;
      });

  void createGroup() {
    // prompt user the group name
    showAlertDialog(
      context: context,
      title: null,
      msg: 'Create a new group!',
      msgWidget: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: MVTextInput(
          hintText: "Group Name",
          controller: gc,
        ),
      ),
      footer: 'N/B: Members can later search for your group and join!',
      onOk: () {
        // disable create group button
        setState(() {
          createGroupEnabled = false;
        });

        sc.createDoc(collectionName: 'groups', data: {
          "sourceId": sc.username.value,
          "name": groupName,
          "dstEntities": [sc.username.value],
        }).then((_) {
          // clear previous group name
          gc.clear();

          // reset group button
          setState(() {
            createGroupEnabled = true;
          });

          // todo: navigate to group after creation
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => sc.groups.isNotEmpty
        ? SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
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
                    itemCount: sc.groups.length,
                    itemBuilder: (BuildContext context, int index) {
                      Group g = sc.groups[index];
                      return GroupTile(
                        lastProfile: g.lastProfile,
                        posted: g.created,
                        grpName: g.name,
                        lastMsg: g.lastMessage,
                        msgsCount: g.count,
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        : EmptyMsg(
            lottiePath: 'assets/lottie/16952-group-working.json',
            title: 'Groups',
            message: 'Connect and discuss with several like minded people!',
            child: getGroupsAction(),
          ));
  }

  InterfaceButton getGroupsAction() => InterfaceButton(
        label: 'Create Group',
        icon: Icons.group_add,
        onPressed: createGroupEnabled ? createGroup : null,
        bgColor: createGroupEnabled ? null : Colors.grey,
      );

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
    this.lastProfile,
    required this.grpName,
    required this.lastMsg,
    required this.posted,
    required this.msgsCount,
  });

  final UserProfile? lastProfile;
  final String grpName;
  final String lastMsg;
  final DateTime? posted;
  final int msgsCount;

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
                const Icon(Icons.group, size: 60),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        grpName,
                        style: const TextStyle(fontSize: 12, color: htSolid4),
                      ),
                      Row(
                        children: [
                          if (lastProfile != null)
                            StaticAvatarSegment(
                                isCircular: true,
                                size: 18,
                                path: lastProfile!.avatar.isNotEmpty
                                    ? lastProfile!.avatar
                                    : 'assets/images/user.png'),
                          if (lastProfile != null) const SizedBox(width: 5),
                          Text(
                            lastMsg,
                            style: TextStyle(
                                fontStyle: lastProfile != null
                                    ? null
                                    : FontStyle.italic,
                                fontSize: 17,
                                color:
                                    lastProfile != null ? htSolid5 : htSolid2,
                                height: lastProfile != null ? null : 1.5),
                          ),
                        ],
                      ),
                      if (posted != null)
                        Text(
                          timeago.format(posted!),
                          style: const TextStyle(
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
            NumberCircleCount(value: msgsCount, fontSize: 15),
          ],
        ),
      ),
    );
  }
}
