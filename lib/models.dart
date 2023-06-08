// Models File : All objects used in the app defined here

import 'package:appwrite/models.dart';

class UserProfile {
  // user profile object

  String username;
  String name;
  String bio;
  String avatar;
  String? id;

  // use default values if not provided
  UserProfile({
    required this.username,
    this.name = "John Doe",
    this.bio = "Hi there, I'm new here!",
    this.avatar = "",
    this.id,
  });

  factory UserProfile.fromDoc(Document doc) {
    // init from doc
    return UserProfile(
      name: doc.data['name'],
      avatar: doc.data['avatar'] ?? '',
      username: doc.$id,
      bio: doc.data['bio'],
      id: doc.data['userId'],
    );
  }

  factory UserProfile.fromJson(Map json) {
    // init from json
    return UserProfile(
      name: json['name'],
      avatar: json['avatar'],
      username: json["\$id"],
      bio: json['bio'],
      id: json['userId'],
    );
  }
}

class Message {
  // message object

  String id;
  UserProfile profile;
  String text;
  List<String> images;
  String video;
  String link;
  List<String> tags;
  List<String> readers;
  DateTime? created;
  bool seen;
  bool grpDst;
  Message? reply;

  // use default values if not provided
  Message({
    required this.id,
    required this.profile,
    required this.text,
    this.images = const [],
    this.readers = const [],
    this.video = '',
    this.link = '',
    this.grpDst = false,
    this.tags = const [],
    this.seen = false,
    this.reply,
    created,
  }) {
    this.created = created ?? DateTime.now().toUtc();
  }

  factory Message.fromDoc(
      {required Document doc, required UserProfile profile}) {
    // init from doc
    return Message(
      id: doc.$id,
      profile: profile,
      text: doc.data['text'],
      grpDst: doc.data['toGroup'] ?? false,
      created: DateTime.parse(doc.$createdAt),
      video: doc.data['video'] ?? '',
      link: doc.data['link'] ?? '',
      readers: doc.data['isRead'].cast<String>(),
    );
  }

  factory Message.fromJson({required Map json, required UserProfile profile}) {
    // init from json
    return Message(
      id: json['\$id'],
      profile: profile,
      text: json['text'],
      grpDst: json['toGroup'] ?? false,
      created: DateTime.parse(json['\$createdAt']),
      video: json['video'] ?? '',
      link: json['link'] ?? '',
      readers: json['isRead'],
    );
  }
}

class Conversation {
  // conversation object
  UserProfile profile;

  DateTime created;
  String? lastMessage;
  int count;

  Conversation({
    required this.profile,
    required this.created,
    this.lastMessage,
    this.count = 0,
  });
}

class Group {
  // groups object
  List<UserProfile>? profiles;

  String id;
  String name;
  String? logo;
  String? admin;
  List? members;
  List? requests;
  DateTime? lastPosted;
  DateTime? created;
  String lastMessage;
  UserProfile? lastProfile;
  bool isPrivate;
  int count;

  Group({
    this.profiles,
    this.lastProfile,
    this.logo,
    required this.name,
    this.lastPosted,
    this.admin,
    this.created,
    this.requests,
    this.members,
    this.isPrivate = false,
    required this.id,
    this.lastMessage = '',
    this.count = 0,
  });

  factory Group.fromDoc(Document doc) {
    // init from doc
    return Group(
      name: doc.data['name'],
      logo: doc.data['logo'],
      members: doc.data['dstEntities'],
      admin: doc.data['sourceId'],
      requests: doc.data['requestIds'],
      isPrivate: doc.data['isPrivate'] ?? false,
      created: DateTime.parse(doc.$createdAt),
      id: doc.$id,
    );
  }
}

class SearchData {
  // search object
  UserProfile? profile;
  Group? group;
  DateTime created;

  SearchData({this.profile, this.group, required this.created});

  factory SearchData.fromDoc(Document doc) {
    if (doc.data.containsKey('logo')) {
      return SearchData(
        group: Group(name: doc.data['name'], profiles: [], id: doc.$id),
        created: DateTime.parse(doc.$createdAt),
      );
    }
    return SearchData(
      profile: UserProfile.fromDoc(doc),
      created: DateTime.parse(doc.$createdAt),
    );
  }
}

class MVNotification {
  // notification object
  String id;
  UserProfile? profile;
  String? title;
  Map? body;
  DateTime created;

  MVNotification({
    this.profile,
    this.title,
    this.body,
    required this.created,
    required this.id,
  });
}
