import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as AppwriteModels;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mindverse/utils.dart';
import 'package:mindverse/models.dart';

final List<String> lightProfileColumns = [
  'bio',
  'name',
  'avatar',
  'image',
  'userId',
  'enLocation',
  'lastOnline',
];

class SessionController extends GetxController {
  var onlineStatus = RxMap({});

  var profiles = RxMap();
  var prefs = RxMap();
  var userId = ''.obs;
  var username = 'unknown'.obs;
  var name = 'John Doe'.obs;
  var image = ''.obs;
  var bio = ''.obs;
  var email = ''.obs;
  var verified = false.obs;
  var actionStatus = false.obs;
  var enLocation = false.obs;
  var lastOnline = ''.obs;

  late final Client _client;
  late final Account _account;
  late final Databases _database;
  late final Realtime _realtime;

  late final AppWriteDetails _appDetails;

  Map collections = {};
  Map storages = {};

  Future sendVerification() => _account.createVerification(
        url: '${_appDetails.website}/verification',
      );

  setActionStatus(bool result) => actionStatus.value = result;

  setBio(String txt) => bio.value = txt;

  setLoc(bool en) => enLocation.value = en;

  setName(String nme) => name.value = nme;

  getRealtime() => _realtime;

  getAppDetails() => _appDetails;

  getCollections() => collections;

  Future setUserDetails() => _account.get().then((account) async {
        // update user details
        userId.value = account.$id;
        name.value = account.name;
        verified.value = account.emailVerification || account.phoneVerification;
        email.value = account.email;

        for (var pKey in account.prefs.data.keys) {
          if (pKey == 'username') {
            username.value = account.prefs.data['username'];
          }
          prefs[pKey] = account.prefs.data[pKey];
        }

        onlineStatus[username.value] = DateTime.now().toUtc();

        return true;
      }).catchError((exception) => false);

  Future _loadEnvVariables() async {
    await dotenv.load(fileName: ".env");

    collections = jsonDecode(dotenv.env['COLLECTIONS']!);
    storages = jsonDecode(dotenv.env['STORAGES']!);
  }

  Future<Account> init() async {
    // load env variables
    await _loadEnvVariables();

    // load appwrite
    AppWriteDetails appDetails = AppWriteDetails();
    await appDetails.loadEnvDetails();

    _appDetails = appDetails;

    _client = Client(
      endPoint: '${appDetails.host}/v1',
      selfSigned: true,
    ).setProject(appDetails.projectId).setSelfSigned();

    _account = Account(_client);
    _database = Databases(_client);
    _realtime = Realtime(_client);
    return _account;
  }

  Future login({required String email, required String password}) =>
      _account.createEmailSession(email: email, password: password);

  Future logout() => _account.deleteSession(sessionId: "current");

  Future register({required String email, required String password}) =>
      _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

  Future reset({required String email}) => _account.createRecovery(
        email: email,
        url: '${_appDetails.website}/recovery',
      );

  Future setPrefs({required Map newPrefs}) {
    for (var pKey in newPrefs.keys) {
      if (pKey == 'username') {
        username.value = newPrefs[pKey];
      }
      prefs[pKey] = newPrefs[pKey];
    }

    return _account.updatePrefs(
      prefs: newPrefs,
    );
  }

  Future updateName({required String nme}) {
    setName(nme);

    return _account.updateName(
      name: nme,
    );
  }

  // light profile loader
  Future<UserProfile> getProfile(
      {required String uname, bool newDetails = false}) async {
    // check if profile already processed
    if (profiles.containsKey(uname) && !newDetails) {
      // check if stored profile is valid by 1 hrs
      if (profiles[uname]['checked'].millisecondsSinceEpoch >
          DateTime.now().toUtc().millisecondsSinceEpoch - 60000 * 60) {
        return UserProfile.fromDoc(profiles[uname]['doc']);
      }
    }

    return getDoc(collectionName: "profiles", docId: uname).then((doc) {
      // update online status
      onlineStatus[uname] = DateTime.parse(doc.data['lastOnline']);

      // store profile for future ref
      profiles[uname] = {'checked': DateTime.now().toUtc(), 'doc': doc};
      return UserProfile.fromDoc(doc);
    });
  }

  Future<bool> checkOnline({required String uname}) async {
    // check if current user is online
    if (username.value == uname || uname == 'unknown') {
      return true;
    }

    if (onlineStatus.containsKey(uname)) {
      // check if period expired (180s)
      DateTime lastUpdate = onlineStatus[uname];
      if (lastUpdate.millisecondsSinceEpoch >
          DateTime.now().toUtc().millisecondsSinceEpoch - 180000) {
        return true;
      }
    }
    return await getDoc(collectionName: "profiles", docId: uname).then((doc) {
      if (DateTime.parse(doc.data['lastOnline']).millisecondsSinceEpoch >
          DateTime.now().toUtc().millisecondsSinceEpoch - 180000) {
        // update online status
        onlineStatus[uname] = DateTime.parse(doc.data['lastOnline']);
        return true;
      }
      return false;
    });
  }

  Future getContacts({required String uname}) =>
      getDoc(collectionName: "secrets", docId: uname)
          .then((doc) => doc.data['contacts']);

  Future getDocs({required String collectionName, List<String>? queries}) =>
      _database.listDocuments(
          databaseId: _appDetails.databaseId,
          collectionId: collections[collectionName],
          queries: queries);

  Future getDoc({required String collectionName, required String docId}) =>
      _database.getDocument(
          databaseId: _appDetails.databaseId,
          collectionId: collections[collectionName],
          documentId: docId);

  Future updateDoc(
          {required String collectionName,
          required String docId,
          required Map data}) =>
      _database.updateDocument(
          databaseId: _appDetails.databaseId,
          collectionId: collections[collectionName],
          documentId: docId,
          data: data);

  Future setProfile({required String uname, required Map data}) =>
      _database.createDocument(
          databaseId: _appDetails.databaseId,
          collectionId: collections["profiles"],
          documentId: uname,
          data: data);

  Future updateProfile({required Map data}) =>
      updateDoc(collectionName: 'profiles', docId: username.value, data: data);
}

class ChatController extends GetxController {
  var muteVideos = true.obs;
  var videoPosition = {}.obs;

  var conversations = RxList();
  RxList recentMessages = RxList();
  RxList messages = RxList([
    Message(
      id: 'test1',
      profile: UserProfile(username: 'maineM'),
      text: 'hello',
    ),
    Message(
      id: 'test2',
      profile: UserProfile(username: 'johnnash'),
      text: 'hello you',
    ),
    Message(
      id: 'test3',
      profile: UserProfile(username: 'johnnash'),
      text: 'check out these #pix',
      images: [
        "https://picsum.photos/id/237/200/300",
        "https://picsum.photos/seed/picsum/200/300",
        "https://picsum.photos/200/300?grayscale",
        "https://picsum.photos/200/300",
        "https://picsum.photos/200/300?grayscale"
      ],
    ),
    Message(
      id: '24bjb3h5',
      text: "testing #video display",
      video:
          "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4",
      profile: UserProfile(username: 'maineM'),
    ),
    Message(
      id: 'test2s',
      profile: UserProfile(username: 'johnnash'),
      text: 'did you see this!',
      reply: Message(
        id: 'test3',
        profile: UserProfile(username: 'maineM'),
        text: 'check out these #pix',
        images: [
          "https://picsum.photos/id/237/200/300",
          "https://picsum.photos/seed/picsum/200/300",
          "https://picsum.photos/200/300?grayscale",
          "https://picsum.photos/200/300",
          "https://picsum.photos/200/300?grayscale"
        ],
      ),
    ),
    Message(
      id: '24bjb3h5',
      text: "hello #world check out this video",
      link:
          'https://nation.africa/kenya/counties/nairobi/green-park-the-sh250-million-matatu-stage-no-one-wants-4155986',
      profile: UserProfile(username: 'johnnash'),
    ),
  ]);

  setGlobalMute(bool muted) {
    muteVideos.value = muted;
  }

  setCurrentVideoPosition(String vid, int pos) {
    videoPosition[vid] = pos;
  }

  addMessage(Message msg) => messages.insert(0, msg);

  addRecentMessage({required Map data}) => recentMessages.add(data);

  addConversation(Conversation con) => conversations.add(con);

  clearConversations() => conversations.clear();

  swapConversation(int index, Conversation updatedConversation) {
    conversations.removeAt(index);
    conversations.insert(index, updatedConversation);
  }

  clearMessages() => messages.clear();

  markAllRead({required SessionController ses}) async {
    List<String> processed = [];
    for (Message msg in messages) {
      // check for unread messages
      if (msg.profile.username != ses.username.value &&
          !msg.seen &&
          !processed.contains(msg.id)) {
        // mark read
        await ses.updateDoc(
          collectionName: 'messages',
          docId: msg.id,
          data: {"isRead": true},
        ).then((_) => msg.seen = true);
        processed.add(msg.id);
      }
    }
    update();
  }

  clearRecentMessages() => recentMessages.clear();

  Future getConversations(
          {required SessionController ses, required String username}) =>
      ses
          .getDoc(collectionName: "secrets", docId: username)
          .then((doc) => doc.data['conversations']);

  Future<AppwriteModels.Document>? getLastConversation(
          {required SessionController ses, required String username}) async =>
      await ses.getDocs(collectionName: 'messages', queries: [
        Query.equal('isChat', [true]),
        Query.equal('profile', [ses.username.value, username]),
        Query.equal('dstProfile', [username, ses.username.value]),
        Query.orderDesc('\$createdAt'),
        Query.limit(1),
      ]).then((docs) => docs.documents.length > 0 ? docs.documents[0] : null);

  Future getMessages(
      {required SessionController ses,
      required String username,
      required bool bottom}) async {
    // define global queries
    List<String> queries = [
      Query.equal('isChat', [true]),
      Query.equal('profile', [ses.username.value, username]),
      Query.equal('dstProfile', [username, ses.username.value]),
      Query.orderDesc('\$createdAt'),
      Query.limit(10),
    ];

    if (bottom && messages.isNotEmpty) {
      queries.add(Query.cursorAfter(messages.last.id));
    }
    // get messages
    await ses
        .getDocs(collectionName: 'messages', queries: queries)
        .then((docs) async {
      if (!bottom) {
        // clear messeges if not initiated from bottom
        //messages.clear();
      }

      // process reversed documents order
      for (AppwriteModels.Document doc in docs.documents) {
        UserProfile owner =
            await ses.getProfile(uname: doc.data['profile']['\$id']);
        Message newMessage = Message(
          id: doc.$id,
          profile: owner,
          text: doc.data['text'],
          created: DateTime.parse(doc.$createdAt),
          seen: doc.data['isRead'],
          video: doc.data['video'],
          link: doc.data['link'],
        );

        // add images if exists
        if (doc.data['images'].length > 0) {
          newMessage.images = doc.data['images'];
        }

        // get referenced message
        if (doc.data['replyId'] != null) {
          await ses
              .getDoc(collectionName: 'messages', docId: doc.data['replyId'])
              .then((rDoc) async {
            UserProfile rOwner =
                await ses.getProfile(uname: rDoc.data['profile']['\$id']);
            Message refMessage = Message(
              id: rDoc.$id,
              profile: rOwner,
              text: rDoc.data['text'],
              created: DateTime.parse(rDoc.$createdAt),
              seen: rDoc.data['isRead'],
              video: rDoc.data['video'],
              images: rDoc.data['images'] as List<String>,
              link: rDoc.data['link'],
            );

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
        messages.add(newMessage);
      }
    });
  }
}

class HTSearchController extends GetxController {
  var results = <SearchData>[].obs;
  var processedResults = [].obs;

  // top 20 trend suggestions
  var trends = <SearchData>[].obs;

  Future getTrends({required SessionController ses}) async {
    // clear trends
    trends.clear();

    await ses.getDocs(collectionName: 'trends', queries: [
      // Query.select(['tag']),
      Query.orderDesc('\$createdAt'),
      Query.limit(500),
    ]).then((res) {
      Map<String, int> tally = {};
      for (AppwriteModels.Document doc in res.documents) {
        // get new entry
        SearchData newEntry = SearchData.fromDoc(doc);

        if (tally.containsKey(newEntry.group!.name)) {
          tally[newEntry.group!.name] = tally[newEntry.group!.name]! + 1;
        } else {
          tally[newEntry.group!.name] = 1;
        }
      }

      // add ordered list to trends list
      List<MapEntry<String, int>> sortedTally = tally.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      for (var e in sortedTally.reversed) {
        // use order to list trends
        for (AppwriteModels.Document doc in res.documents) {
          // get new entry
          SearchData newEntry = SearchData.fromDoc(doc);

          if (e.key == newEntry.group!.name) {
            // add to trends
            trends.add(newEntry);
            break;
          }
        }
      }
    });
  }

  void processSearch(
      {required AppwriteModels.DocumentList result, bool isTag = false}) {
    for (AppwriteModels.Document doc in result.documents) {
      if (!processedResults.contains(doc.$id)) {
        // get new entry
        SearchData newEntry = SearchData.fromDoc(doc);
        if (results.isNotEmpty) {
          // sort results
          int ix = 0;
          bool added = false;
          for (SearchData entry in results) {
            if (entry.created.millisecondsSinceEpoch <
                newEntry.created.millisecondsSinceEpoch) {
              added = true;
              results.insert(ix, newEntry);
              break;
            }
            ix += 1;
          }
          if (!added) {
            results.add(newEntry);
          }
        } else {
          results.add(newEntry);
        }

        // mark id
        processedResults.add(doc.$id);
      }
    }
  }

  Future search({required String q, required SessionController ses}) async {
    // clear previous results
    results.clear();
    processedResults.clear();

    // search profile names
    await ses.getDocs(collectionName: 'profiles', queries: [
      // Query.select(lightProfileColumns),
      Query.search('name', q),
      Query.orderDesc('\$createdAt'),
      Query.limit(10),
    ]).then((res) => processSearch(result: res));

    // search profile username
    await ses.getDocs(collectionName: 'profiles', queries: [
      // Query.select(lightProfileColumns),
      Query.search('\$id', q),
      Query.orderDesc('\$createdAt'),
      Query.limit(10),
    ]).then((res) => processSearch(result: res));

    // search feed tags
    await ses.getDocs(collectionName: 'trends', queries: [
      // Query.select(['tag']),
      Query.search('tag', q),
      Query.orderDesc('\$createdAt'),
      Query.limit(10),
    ]).then((res) => processSearch(result: res, isTag: true));
  }
}
