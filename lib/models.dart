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

  factory UserProfile.fromDoc(doc) {
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
  DateTime? created;
  bool seen;
  Message? reply;

  // use default values if not provided
  Message({
    required this.id,
    required this.profile,
    required this.text,
    this.images = const [],
    this.video = '',
    this.link = '',
    this.tags = const [],
    this.seen = false,
    this.reply,
    created,
  }) {
    this.created = created ?? DateTime.now().toUtc();
  }

  factory Message.fromDoc(Document doc) {
    // init from doc
    return Message(
      id: '',
      profile: UserProfile(username: 'unknown'),
      text: doc.data['text'],
    );
  }

  // factory Message.fromJson(Map json) {
  //   // init from json
  //   return Message(
  //     name: json['name'],
  //     avatar: json['avatar'],
  //     username: json["\$id"],
  //     bio: json['bio'],
  //   );
  // }
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

  String? id;
  String name;
  DateTime? created;
  String lastMessage;
  UserProfile? lastProfile;
  int count;

  Group({
    this.profiles,
    this.lastProfile,
    required this.name,
    this.created,
    this.id = '',
    this.lastMessage = '',
    this.count = 0,
  });
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
        group: Group(name: doc.data['name'], profiles: []),
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
