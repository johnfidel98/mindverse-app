import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/ad.dart';
import 'package:mindverse/components/images.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/components/video.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'dart:math' as math;

const uuid = Uuid();

class ConversationPage extends StatefulWidget {
  const ConversationPage({
    super.key,
    this.entityId,
    required this.isGrp,
  });

  // use entityId to monitor for both groups and 1-1 conversations.
  final String? entityId;
  final bool isGrp;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage>
    with WidgetsBindingObserver {
  final ChatController cc = Get.find<ChatController>();
  final SessionController sc = Get.find<SessionController>();

  final ScrollController _scrollController = ScrollController();

  late Realtime _realtime;
  late StreamSubscription _listenerUpdatedMessages;
  late final RealtimeSubscription _newMessagesListener;

  Group groupData = Group(name: 'unknown', id: '#');
  UserProfile profileData = UserProfile(username: unknownBastard);
  bool _reachedEnd = false;
  bool _loadedEntity = false;
  bool _isGroup = false;
  Completer<void> completerEntityLoaded = Completer<void>();

  @override
  void initState() {
    super.initState();

    // monitor scrolling
    _scrollController.addListener(_scrollListener);

    // update loading
    cc.setMessagesLoading(true);

    // load current conversation
    getConversation();

    // setup realtime listening of messages for fast response
    _realtime = sc.getRealtime();

    // get database id from app details
    AppWriteDetails appDetails = sc.getAppDetails();

    // listen for messages changes and mark destined to me as read
    _listenerUpdatedMessages = cc.messages.listen((data) {
      // mark all read
      cc.markAllRead(ses: sc);
    });

    // listen for realtime message events
    _newMessagesListener = _realtime.subscribe([
      'databases.${appDetails.databaseId}.collections.${sc.collections['messages']}.documents',
    ]);

    _newMessagesListener.stream.listen((response) async {
      if (response.events.contains(
          'databases.*.collections.${sc.collections['messages']}.documents.*.create')) {
        // check message
        Map msg = response.payload;

        // check message destined to me
        if (msg['entitiesId'] == sc.username.value) {
          // get owner profle
          UserProfile owner = await sc.getProfile(uname: msg['sourceId']);

          // load message
          cc.addMessage(Message.fromJson(json: msg, profile: owner));
        }
      }
    });
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => postInit());
  }

  void postInit() async {
    // load entity details
    if (widget.isGrp) {
      // load group details
      await sc.getGroup(groupId: widget.entityId!).then((Group g) {
        // update states
        setState(() {
          groupData = g;
          _loadedEntity = true;
          _isGroup = true;
        });

        // complete loaded entity
        completerEntityLoaded.complete();
      });
    } else {
      // load profile details
      await sc.getProfile(uname: widget.entityId!).then((UserProfile p) {
        setState(() {
          profileData = p;
          _loadedEntity = true;
        });

        // complete loaded entity
        completerEntityLoaded.complete();
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels < 300) {
      // Reached the bottom
      if (!_reachedEnd) {
        setState(() {
          _reachedEnd = true;
        });
        getConversation(bottom: true);
      }
    } else {
      if (_reachedEnd) {
        setState(() {
          _reachedEnd = false;
        });
      }
    }
  }

  void getConversation({bool bottom = false}) async {
    // wait for entity to load
    await completerEntityLoaded.future;

    // get conversations from secrets
    await cc.getMessages(
        ses: sc, entityId: widget.entityId!, bottom: bottom, isGroup: _isGroup);
  }

  @override
  void dispose() {
    // close realtime subscription
    _newMessagesListener.close();

    // cancel subscription
    _listenerUpdatedMessages.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        leading: const LeadingBack(),
        titleSpacing: 0,
        title: _loadedEntity
            ? widget.isGrp
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupData.name,
                        style: defaultTextStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: htSolid4,
                        ),
                      ),
                      if (groupData.isPrivate)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.lock,
                            color: htSolid4,
                            size: 16,
                          ),
                        ),
                    ],
                  )
                : NamingSegment(
                    owner: profileData,
                    size: 20,
                    rowAlignment: MainAxisAlignment.start,
                    height: 1.8,
                  )
            : Text(
                'Loading ...',
                style: defaultTextStyle.copyWith(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
        backgroundColor: Colors.white,
        actions: _isGroup
            ? [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.view_list,
                    color: htSolid5,
                  ),
                ),
                if (groupData.admin == sc.username.value)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person_add,
                        color: htSolid5,
                      ),
                    ),
                  )
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Obx(
                () => cc.loadingMessages.value
                    ? const GeneralLoading(
                        artifacts: 'Messages',
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: cc.messages.length,
                        itemBuilder: (context, index) {
                          Message messageData = cc.messages[index];
                          var msgUser = messageData.profile.username;
                          var currentUser = sc.username.value;
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: msgUser == currentUser ? 20.0 : 5.0,
                                  right: msgUser == currentUser ? 5.0 : 20.0,
                                ),
                                child: Card(
                                  margin: const EdgeInsets.only(
                                      top: 15.0, bottom: 2),
                                  color: msgUser == currentUser
                                      ? htSolid1
                                      : Colors.grey[100],
                                  elevation: 2,
                                  child: ConversationComponent(
                                    messageData: messageData,
                                    session: sc,
                                  ),
                                ),
                              ),
                              index % 8 == 0
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 15.0),
                                      child: AdaptiveAdvert(),
                                    )
                                  : const SizedBox(),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
          ChatInputBar(
            isGroup: _isGroup,
            entitiesId: widget.entityId!,
          ),
        ],
      ),
    );
  }
}

class ConversationComponent extends StatelessWidget {
  final Message messageData;
  final SessionController session;

  const ConversationComponent({
    super.key,
    required this.messageData,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    var msgUser = messageData.profile.username;
    var currentUser = session.username.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          messageData.reply != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Transform.rotate(
                              angle: msgUser == currentUser
                                  ? 180 * math.pi / 180
                                  : 0 * math.pi / 180,
                              child: const Icon(Icons.reply, size: 14)),
                        ),
                        Text(
                          messageData.profile.name,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "@${messageData.profile.username}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    Text(
                      messageData.text,
                      style: const TextStyle(fontSize: 18, height: 1.3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        elevation: 2,
                        color: msgUser == currentUser
                            ? Colors.grey[100]
                            : htSolid1,
                        child: ConversationComponent(
                          messageData: messageData.reply!,
                          session: session,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      messageData.profile.name,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "@${messageData.profile.username}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
          if (messageData.reply == null)
            Padding(
              padding: EdgeInsets.only(
                  bottom: messageData.reply == null ? 2.0 : 8.0),
              child: Text(
                messageData.text,
                style: const TextStyle(fontSize: 18, height: 1.3),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: messageData.images.isNotEmpty
                ? ImagesSegment(images: messageData.images, height: 300)
                : messageData.video.isNotEmpty
                    ? SizedBox(
                        height: 300,
                        child: VideoSegment(
                            id: "msg-video-${messageData.id}",
                            video: messageData.video),
                      )
                    : messageData.link.isNotEmpty
                        ? LinkSegment(link: messageData.link)
                        : const SizedBox(),
          ),
          Row(
            children: [
              Text(
                timeago.format(DateTime.parse(messageData.created.toString())),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Icon(messageData.seen ? Icons.done_all : Icons.check,
                    size: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
