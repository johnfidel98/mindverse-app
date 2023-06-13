import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/ad.dart';
import 'package:mindverse/pages/homeTabs/contacts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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

  late final PanelController _controllerSlidePanel;

  @override
  void initState() {
    super.initState();

    _controllerSlidePanel = PanelController();

    // my last conversations
    cc.getConversations(sc: sc, username: sc.username.value);
  }

  void createConversation() => _controllerSlidePanel.open();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Obx(
            () => RefreshIndicator(
              onRefresh: () =>
                  cc.getConversations(sc: sc, username: sc.username.value),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RoamCard(),
                    ),
                    cc.conversations.isNotEmpty
                        ? HomeTitle(
                            title: 'Conversations',
                            statsWidget: getConvAction('New'),
                          )
                        : const SizedBox(),
                    cc.conversations.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
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
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: NativeAdvert(),
                                          )
                                        : const SizedBox(),
                                  ],
                                );
                              },
                            ),
                          )
                        : Container(
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
            ),
          ),
        ),
        SlidingUpPanel(
          color: Colors.grey.shade200,
          maxHeight: MediaQuery.of(context).size.height / 1.5,
          minHeight: 20,
          controller: _controllerSlidePanel,
          panel: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ContactListing(
              known: true,
              onDrawer: true,
              cancel: () => _controllerSlidePanel.close(),
            ),
          ),
        ),
      ],
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
                                width: MediaQuery.of(context).size.width - 120,
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
