import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mindverse/utils.dart';
import 'package:mindverse/models.dart';

class SessionController extends GetxController {
  var onlineStatus = RxMap({});
  var notifications = RxList([]);

  var profiles = RxMap();
  var groups = RxMap();
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

  Future getNotifications() async =>
      await getDocs(collectionName: 'notifications', queries: [
        Query.search('destinationId', username.value),
        Query.orderDesc('\$createdAt'),
        Query.limit(100),
      ]).then((res) async {
        // clear current notifications
        notifications.clear();

        for (aw.Document doc in res.documents) {
          // sync profile
          UserProfile profile = await getProfile(uname: doc.data['sourceId']);

          // process notification
          notifications.add(MVNotification(
            id: doc.$id,
            title: doc.data['title'],
            profile: profile,
            created: DateTime.parse(doc.$createdAt),
            body: jsonDecode(doc.data['body']),
          ));
        }
      });

  Future removeNotification(
          {required int index, required String docId}) async =>
      await deleteDoc(collectionName: 'notifications', docId: docId).then((_) {
        notifications.removeAt(index);
        notifications.refresh();
      });

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

  Future<Group> getGroup(
      {required String groupId, bool newDetails = false}) async {
    // check if group already processed
    if (groups.containsKey(groupId) && !newDetails) {
      // check if stored group is valid by 1 hrs
      if (groups[groupId]['checked'].millisecondsSinceEpoch >
          DateTime.now().toUtc().millisecondsSinceEpoch - 60000 * 60) {
        return Group.fromDoc(groups[groupId]['doc']);
      }
    }

    return getDoc(collectionName: "groups", docId: groupId).then((doc) {
      // store group for future ref
      groups[groupId] = {'checked': DateTime.now().toUtc(), 'doc': doc};

      // return group
      return Group.fromDoc(doc);
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

  Future createDoc({required String collectionName, required Map data}) =>
      _database.createDocument(
          databaseId: _appDetails.databaseId,
          collectionId: collections[collectionName],
          documentId: ID.unique(),
          data: data);

  Future deleteDoc({required String collectionName, required String docId}) =>
      _database.deleteDocument(
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