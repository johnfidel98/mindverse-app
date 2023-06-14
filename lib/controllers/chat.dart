import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:get/get.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';

class ChatController extends GetxController {
  var muteVideos = true.obs;
  var videoPosition = {}.obs;

  var groups = RxList([]);
  var loadingGroups = false.obs;
  var firstLoadGroups = false.obs;
  var processedGroupIds = RxList([]);

  var conversations = RxList();
  var loadingConversations = false.obs;
  var firstLoadConversations = false.obs;
  var processedConversationsIds = RxList();

  var loadingMessages = true.obs;
  var messages = RxList([]);

  setGlobalMute(bool muted) => muteVideos.value = muted;

  setMessagesLoading(bool loading) => loadingMessages.value = loading;

  setCurrentVideoPosition(String vid, int pos) => videoPosition[vid] = pos;

  addMessage(Message msg) => messages.insert(0, msg);

  markAllRead({required SessionController ses}) async {
    List<String> processed = [];
    for (Message msg in messages) {
      // check for unread messages
      if (msg.profile.username != ses.username.value &&
          !msg.seen &&
          !processed.contains(msg.id)) {
        // init readers
        List<String> readers = [];
        if (msg.grpDst) {
          // get current status for message
          Message currentMessage = await getMessage(ses: ses, mid: msg.id);

          // add existing readers from current message
          readers.addAll(currentMessage.readers);
        }

        if (!readers.contains(ses.username.value)) {
          // add user
          readers.add(ses.username.value);
          // mark read
          await ses.updateDoc(
            collectionName: 'messages',
            docId: msg.id,
            data: {"isRead": readers},
          ).then((_) {
            // update message
            msg.seen = true;
            msg.readers = readers;
          });
        }

        processed.add(msg.id);
      }
    }

    update();
  }

  Future<Message> getMessage(
          {required SessionController ses, required String mid}) async =>
      await ses
          .getDoc(collectionName: 'messages', docId: mid)
          .then((mDoc) async {
        // resolve profile
        UserProfile mProfile =
            await ses.getProfile(uname: mDoc.data['sourceId']);

        // return message
        return Message.fromDoc(doc: mDoc, profile: mProfile);
      });

  Future getGroups({required SessionController sc}) async {
    // set loading
    loadingGroups.value = true;

    return await sc.getDocs(collectionName: 'groups', queries: [
      Query.search('dstEntities', '"${sc.username.value}"'),
      Query.orderDesc('\$createdAt'),
      Query.limit(100),
    ]).then((res) async {
      for (aw.Document doc in res.documents) {
        // sync group basic details
        Group grp = Group.fromDoc(doc);

        // get groups' last message
        List<aw.Document> msgDocs = await getGroupConversation(
          ses: sc,
          groupId: doc.$id,
        );
        if (msgDocs.isNotEmpty) {
          // get last message user details
          UserProfile msgProfile =
              await sc.getProfile(uname: msgDocs[0].data['sourceId']);
          grp.lastMessage = '${msgDocs[0].data["text"]}';

          int cnt = 0;
          for (aw.Document mDoc in msgDocs) {
            // only count ones not read by me
            if (!mDoc.data['isRead'].contains(sc.username.value) &&
                mDoc.data['sourceId'] != sc.username.value) {
              cnt += 1;
            }
          }
          grp.count = cnt;
          grp.lastProfile = msgProfile;
          grp.lastPosted = DateTime.parse(msgDocs[0].$createdAt);
        } else {
          grp.lastMessage = 'Say hello 👋 ...';
        }

        // ensure duplicate groups are not processed
        if (!processedGroupIds.contains(doc.$id)) {
          // add new to groups
          groups.add(grp);

          // add group to processed list
          processedGroupIds.add(grp.id);
        } else {
          // get group index
          int ix = processedGroupIds.indexOf(grp.id);

          // check for changes
          if (groups[ix].lastMessage != grp.lastMessage) {
            // update group details
            groups.removeAt(ix);
            groups.insert(ix, grp);
          }
        }
      }

      // update loading
      loadingGroups.value = false;
      firstLoadGroups.value = true;
    });
  }

  Future getConversations(
      {required SessionController sc, required String username}) async {
    // set loading
    loadingConversations.value = true;

    return await sc
        .getDoc(collectionName: "secrets", docId: username)
        .then((doc) async {
      List<Map<String, dynamic>> rawConversations = [];
      for (String uname in doc.data['conversations']) {
        // get user profile data
        UserProfile profile = await sc.getProfile(uname: uname);

        // create conversation
        Conversation cnv = Conversation(
          profile: profile,
          created: DateTime.now(),
        );

        // get last messages details with other party
        List<aw.Document> msgDocs =
            await getLastConversations(ses: sc, username: profile.username);

        int cnt = 0;
        for (aw.Document mDoc in msgDocs) {
          // only count ones not read by me
          if (!mDoc.data['isRead'].contains(username) &&
              username != sc.username.value) {
            cnt += 1;
          }
        }

        // update messages count
        cnv.count = cnt;

        Map<String, dynamic> cMap = {};
        if (msgDocs.isNotEmpty) {
          // update conversation details
          cnv.lastMessage = msgDocs[0].data['text'];
          cnv.created = DateTime.parse(msgDocs[0].$createdAt);
        }
        // update ordering list
        cMap['cr'] = cnv.created.millisecondsSinceEpoch;
        cMap['cn'] = cnv;
        cMap['un'] = uname;

        rawConversations.add(cMap);
      }

      // order conversations
      rawConversations.sort((mapA, mapB) => mapA["cr"].compareTo(mapB["cr"]));

      // finalize processing
      for (Map conv in rawConversations.reversed) {
        // ensure duplicate conversations are not processed
        if (!processedConversationsIds.contains(conv['un'])) {
          // add new conv to conversations
          conversations.add(conv['cn']);

          // add conversation to processed list
          processedConversationsIds.add(conv['un']);
        } else {
          // get conversation index
          int ix = processedConversationsIds.indexOf(conv['un']);

          // check for changes
          if (conversations[ix].lastMessage != conv['cn'].lastMessage) {
            // update conversations details
            conversations.removeAt(ix);
            conversations.insert(ix, conv['cn']);
          }
        }
      }

      // update loading
      loadingConversations.value = false;
      firstLoadConversations.value = true;
    });
  }

  Future<List<aw.Document>> getLastConversations(
          {required SessionController ses, required String username}) async =>
      await ses.getDocs(collectionName: 'messages', queries: [
        Query.equal('sourceId', [ses.username.value, username]),
        Query.equal('entitiesId', [username, ses.username.value]),
        Query.orderDesc('\$createdAt'),
        Query.limit(11),
      ]).then((docs) => docs.documents.isNotEmpty ? docs.documents : []);

  Future<List<aw.Document>> getGroupConversation(
          {required SessionController ses, required String groupId}) async =>
      await ses.getDocs(collectionName: 'messages', queries: [
        Query.search('entitiesId', groupId),
        Query.orderDesc('\$createdAt'),
        Query.limit(11),
      ]).then((docs) => docs.documents.isNotEmpty ? docs.documents : []);

  Future postMessage(
          {required SessionController ses, required Map data}) async =>
      await ses.createDoc(collectionName: 'messages', data: data);

  Future getMessages(
      {required SessionController ses,
      required String entityId,
      required bool bottom,
      required bool isGroup}) async {
    // define global queries
    List<String> queries = [
      Query.orderDesc('\$createdAt'),
      Query.limit(10),
    ];

    if (isGroup) {
      // add group querries
      queries.add(
        Query.search('entitiesId', entityId),
      );
    } else {
      // add 1 on 1 querries
      queries.addAll([
        Query.equal('sourceId', [ses.username.value, entityId]),
        Query.equal('entitiesId', [entityId, ses.username.value]),
      ]);
    }

    if (bottom && messages.isNotEmpty) {
      queries.add(Query.cursorAfter(messages.last.id));
    }
    // get messages
    await ses
        .getDocs(collectionName: 'messages', queries: queries)
        .then((docs) async {
      if (!bottom) {
        // clear messeges if not initiated from bottom
        messages.clear();
      }

      List<Message> nMessages = [];
      // process reversed documents order
      for (aw.Document doc in docs.documents) {
        UserProfile owner = await ses.getProfile(uname: doc.data['sourceId']);
        Message newMessage = Message.fromDoc(doc: doc, profile: owner);
        newMessage.seen = doc.data['isRead'].contains(ses.username.value);

        // add images if exists
        if (doc.data['images'].length > 0) {
          newMessage.images = doc.data['images'].cast<String>();
        }

        // get referenced message
        if (doc.data['replyId'] != null) {
          await ses
              .getDoc(collectionName: 'messages', docId: doc.data['replyId'])
              .then((rDoc) async {
            UserProfile rOwner =
                await ses.getProfile(uname: rDoc.data['sourceId']);

            Message refMessage = Message.fromDoc(doc: rDoc, profile: rOwner);
            refMessage.seen = rDoc.data['isRead'].contains(ses.username.value);

            // add images if exists
            if (rDoc.data['images'].length > 0) {
              refMessage.images = rDoc.data['images'];
            }
            if (doc.data['replyId'] != null) {
              // set reply message
              newMessage.reply = refMessage;
            }
          });
        }

        // add message to messages
        nMessages.add(newMessage);
      }

      messages.addAll(nMessages);

      // update loading interface
      loadingMessages.value = false;
    });
  }
}
