import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/ad.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/pages/conversation.dart';
import 'package:mindverse/pages/profile.dart';
import 'package:mindverse/utils.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ContactListing(known: true), ContactListing(known: false)],
        ),
      ),
    );
  }
}

class ContactListing extends StatefulWidget {
  const ContactListing(
      {Key? key, this.cancel, this.onDrawer = false, required this.known})
      : super(key: key);

  final Function()? cancel;
  final bool onDrawer;
  final bool known;

  @override
  State<ContactListing> createState() => _ContactListingState();
}

class _ContactListingState extends State<ContactListing>
    with SingleTickerProviderStateMixin {
  final SessionController sc = Get.find<SessionController>();

  bool syncingContacts = false;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();

    // Listen to contact database changes
    FlutterContacts.addListener(processContacts);

    // check contacts on phone
    processContacts();
  }

  void processContacts() async {
    // Request contact permission
    if (await FlutterContacts.requestPermission(readonly: true)) {
      if (_isMounted) {
        setState(() => syncingContacts = true);
      }

      // Get all contacts (lightly fetched)
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);

      // get phone email contacts
      List<String> processedEmails = [];
      Map mContacts = {};
      for (Contact c in contacts) {
        // check if contact exists
        for (Email e in c.emails) {
          if (!processedEmails.contains(e.address)) {
            // add email
            processedEmails.add(e.address);
            mContacts[e.address] = {"n": '${c.name.first} ${c.name.last}'};
          }
        }
      }

      // get current account contacts
      await sc.getContacts(uname: sc.username.value).then((aContacts) async {
        // sync contacts
        for (MVContact cnt in aContacts) {
          if (processedEmails.contains(cnt.email)) {
            // weed out existing in mContacts
            mContacts.remove(cnt.email);
          }
        }

        // merge contacts
        for (String em in mContacts.keys) {
          aContacts.add(MVContact.fromJson(
            json: {"e": em, "u": "", "s": 0, "n": mContacts[em]['n']},
          ));
        }

        if (mContacts.keys.isNotEmpty) {
          // update contacts
          await sc.updateDoc(
              collectionName: 'secrets',
              docId: sc.username.value,
              data: {"contacts": aContacts.map((cL) => cL.toJson()).toList()});
        }

        if (_isMounted) {
          // end sync animation on ui
          setState(() => syncingContacts = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            if (widget.onDrawer) const SlideIndicator(),
            HomeTitle(
              title: widget.known ? 'Contacts' : 'Unknown',
              stats: widget.known
                  ? widget.known
                      ? '${sc.contactsKnown.length} Total'
                      : null
                  : null,
              statsWidget: widget.known
                  ? null
                  : InterfaceButton(
                      label: 'Sync Contacts',
                      onPressed: processContacts,
                      bgColor: syncingContacts ? htSolid2 : null,
                      iconWidget: syncingContacts
                          ? const TinyProgressIndicator()
                          : null),
            ),
            SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.known
                    ? sc.contactsKnown.length
                    : sc.contactsUnknown.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ContactTile(
                          cnt: widget.known
                              ? sc.contactsKnown[index]
                              : sc.contactsUnknown[index]),
                      index % 4 == 0
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: NativeAdvert(),
                            )
                          : const SizedBox(),
                    ],
                  );
                },
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    // cleanup
    _isMounted = false;
    FlutterContacts.removeListener(processContacts);
    super.dispose();
  }
}

class ContactTile extends StatefulWidget {
  const ContactTile({
    super.key,
    required this.cnt,
  });

  final MVContact cnt;

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  bool sentInvite = false;
  bool startingConv = false;

  void startConversation() async {
    setState(() {
      startingConv = true;
    });

    // check if conversation exists
    if (!cc.processedConversationsIds.contains(widget.cnt.username!)) {
      // create conversation
      await sc.startConversation(uname: widget.cnt.username!);
    }

    setState(() {
      startingConv = false;
    });

    // navigate to conversation
    Get.to(() => ConversationPage(entityId: widget.cnt.username, isGrp: false));
  }

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
                if (widget.cnt.profile != null)
                  GestureDetector(
                    onTap: () =>
                        Get.to(() => ProfilePage(profile: widget.cnt.profile!)),
                    child: AvatarSegment(
                      userProfile: widget.cnt.profile!,
                      size: 60,
                      expanded: false,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      left: widget.cnt.profile != null ? 8.0 : 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.cnt.email}',
                        style: defaultTextStyle.copyWith(
                            fontSize: 12, height: 1.2, color: htSolid4),
                      ),
                      Text(
                        widget.cnt.profile != null
                            ? widget.cnt.profile!.name
                            : widget.cnt.name != null
                                ? widget.cnt.name!
                                : 'Unknown Person',
                        style: defaultTextStyle.copyWith(
                            fontSize: 18, height: 1.4, color: htSolid5),
                      ),
                    ],
                  ),
                )
              ],
            ),
            widget.cnt.profile != null
                ? widget.cnt.profile!.username != sc.username.value
                    ? InterfaceButton(
                        iconWidget:
                            startingConv ? const TinyProgressIndicator() : null,
                        onPressed: startConversation,
                        label: 'Chat',
                        icon: startingConv ? null : Icons.chat_bubble,
                        alt: true)
                    : const SizedBox()
                : widget.cnt.email != null
                    ? InterfaceButton(
                        label: sentInvite ? 'Sent' : 'Invite',
                        icon: sentInvite ? Icons.mail_outline : Icons.add,
                        alt: true,
                        onPressed: sentInvite
                            ? () => null
                            : () =>
                                sc.sendInvite(email: widget.cnt.email!).then(
                                  (_) {
                                    // set invite state
                                    setState(() => sentInvite = true);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                        'Invite sent to ${widget.cnt.email!}',
                                        textAlign: TextAlign.center,
                                      )),
                                    );
                                  },
                                ),
                      )
                    : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
