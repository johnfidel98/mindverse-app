import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/ad.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/pages/conversation.dart';
import 'package:mindverse/pages/roam.dart';
import 'package:mindverse/utils.dart';

class ConversationsTab extends StatefulWidget {
  const ConversationsTab({
    super.key,
  });

  @override
  State<ConversationsTab> createState() => _ConversationsTabState();
}

class _ConversationsTabState extends State<ConversationsTab> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();

    // my last conversations
    cc.getConversations(sc: sc, username: sc.username.value);
  }

  void createConversation() {
    // prompt user to select contact
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RoamCard(),
            cc.conversations.isNotEmpty
                ? HomeTitle(
                    title: 'Conversations',
                    statsWidget: getConvAction('New'),
                  )
                : const SizedBox(),
            cc.conversations.isNotEmpty
                ? SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: cc.conversations.length,
                      itemBuilder: (BuildContext context, int index) {
                        Conversation c = cc.conversations[index];
                        return Column(
                          children: [
                            ConversationTile(cnv: c),
                            index % 4 == 0
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    child: NativeAdvert(),
                                  )
                                : const SizedBox(),
                          ],
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: cc.loadingConversations.value &&
                            !cc.firstLoadConversations.value
                        ? const GeneralLoading(
                            artifacts: 'Conversations',
                          )
                        : EmptyMsg(
                            title: 'Conversations',
                            message:
                                'Chat with people, connect and make friends!',
                            child: getConvAction('New Conversation'),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  InterfaceButton getConvAction(String actionName) => InterfaceButton(
        label: actionName,
        icon: Icons.group_add,
        onPressed: createConversation,
      );
}

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.cnv,
  });

  final Conversation cnv;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ConversationPage(
            entityId: cnv.profile.username,
            isGrp: false,
          )),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AvatarSegment(
                    userProfile: cnv.profile,
                    size: 60,
                    expanded: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (cnv.lastMessage != null)
                          NamingSegment(
                            owner: cnv.profile,
                            size: 15,
                            height: 1.3,
                            fontDiff: 4,
                          ),
                        cnv.lastMessage != null
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width - 140,
                                child: Text(
                                  cnv.lastMessage!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.2,
                                    color: htSolid5,
                                  ),
                                ),
                              )
                            : NamingSegment(
                                owner: cnv.profile,
                                size: 18,
                                height: 1.3,
                                fontDiff: 4,
                                vertical: true,
                              ),
                        cnv.lastMessage != null
                            ? Text(
                                timeago.format(cnv.created),
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: htSolid2,
                                ),
                              )
                            : const Text(
                                'Say hello 👋 ...',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                  color: htSolid2,
                                ),
                              )
                      ],
                    ),
                  )
                ],
              ),
              NumberCircleCount(value: cnv.count),
            ],
          ),
        ),
      ),
    );
  }
}
