import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:lottie/lottie.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/components/text_input.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RoamPage extends StatefulWidget {
  const RoamPage({Key? key}) : super(key: key);

  @override
  State<RoamPage> createState() => _RoamPageState();
}

class _RoamPageState extends State<RoamPage> {
  final SessionController sc = Get.find<SessionController>();
  final TextEditingController ec = TextEditingController();

  late final PanelController _controllerSlidePanel;
  List<Map> tagsSelected = [];
  List<String> processedSelected = [];
  List<Map<dynamic, dynamic>> groupsShortlisted = [];
  String search = '';

  @override
  void initState() {
    super.initState();

    _controllerSlidePanel = PanelController();

    // load atlas latest
    sc.getAtlas();

    ec.addListener(_searchTextChanged);
  }

  void _searchTextChanged() => // search latest tags by name
      ec.text.isNotEmpty
          ? sc
              .getAtlas(tag: ec.text)
              .then((_) => setState(() => search = ec.text))
          : _resetTags();

  void _resetTags() => sc.getAtlas().then((_) {
        // reset search
        ec.clear();
        setState(() => search = '');
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const LeadingBack(),
        titleSpacing: 0,
        title: Text(
          '#RoamAbout',
          style: defaultTextStyle.copyWith(
            color: Colors.black87,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    MVTextInput(
                      hintText: 'Search tag ...',
                      controller: ec,
                      prefixIcon: const Icon(Icons.tag),
                      suffixWidget: IconButton(
                          onPressed: _resetTags,
                          icon: Icon(
                              search.isNotEmpty ? Icons.cancel : Icons.search)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8.0),
                      child: Obx(() => RichText(
                            text: TextSpan(children: getTags),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10),
                  child: InterfaceButton(
                    label: 'Reset Tags',
                    onPressed: () => setState(() {
                      tagsSelected = [];
                      processedSelected = [];
                      groupsShortlisted = [];
                    }),
                    alt: tagsSelected.isNotEmpty ? false : true,
                    size: 4,
                  ),
                )
              ],
            ),
          ),
          SlidingUpPanel(
            color: htSolid1,
            maxHeight: MediaQuery.of(context).size.height / 1.3,
            minHeight: groupsShortlisted.isNotEmpty ? 40 : 0,
            slideDirection: SlideDirection.DOWN,
            controller: _controllerSlidePanel,
            panel: RoamGroups(
              groupsS: groupsShortlisted,
              cancel: () => _controllerSlidePanel.close(),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> get getTags {
    List<InlineSpan> allTags = [];
    for (String a in sc.atlas.keys) {
      allTags.addAll([getSpan(a, sc.atlas[a]), const TextSpan(text: ' ')]);
    }
    return allTags;
  }

  TextSpan getSpan(String k, List<String> groups) => TextSpan(
      text: k,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          if (!processedSelected.contains(k)) {
            // stack up tags
            setState(() {
              tagsSelected = [
                ...tagsSelected,
                {'t': k, 'g': groups}
              ];
              processedSelected = [...processedSelected, k];
            });

            // recalculate and resolve groups
            // tally tags per group
            Map<dynamic, dynamic> gs = {};
            for (Map tg in tagsSelected) {
              for (String gr in tg['g']) {
                try {
                  try {
                    gs[gr][tg['t']] = gs[gr][tg['t']] + 1;
                  } catch (e) {
                    gs[gr][tg['t']] = 1;
                  }
                } catch (e) {
                  gs[gr] = {};
                  gs[gr][tg['t']] = 1;
                }
              }
            }

            // future: order by tallies
            List<Map<dynamic, dynamic>> gsList = [];
            for (String grpT in gs.keys) {
              Map gx = {};
              gx[grpT] = gs[grpT];
              gsList.add(gx);
            }

            setState(() {
              groupsShortlisted = gsList;
            });
          }
        },
      style: defaultTextStyle.copyWith(
        fontSize: (18 * (groups.length / 2)).toDouble(),
      ));

  @override
  void dispose() {
    // cleanup
    ec.removeListener(_searchTextChanged);
    super.dispose();
  }
}

class RoamGroups extends StatelessWidget {
  const RoamGroups({
    super.key,
    required this.groupsS,
    required this.cancel,
  });

  final List<Map<dynamic, dynamic>> groupsS;
  final Function() cancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: groupsS.length,
            itemBuilder: (BuildContext context, int index) {
              return GroupShortList(grpShort: groupsS[index]);
            },
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Matched Groups'),
                  Text('${groupsS.length} Total'),
                ],
              ),
            ),
            const Divider(thickness: 1, color: htSolid5, height: 1)
          ],
        )
      ],
    );
  }
}

class GroupShortList extends StatefulWidget {
  const GroupShortList({Key? key, required this.grpShort}) : super(key: key);

  final Map<dynamic, dynamic> grpShort;

  @override
  State<GroupShortList> createState() => _GroupShortListState();
}

class _GroupShortListState extends State<GroupShortList>
    with WidgetsBindingObserver {
  final SessionController sc = Get.find<SessionController>();

  bool loadingGroup = true;
  Group group = Group(id: unknownBastard, name: 'Loading Group ...');

  @override
  void initState() {
    super.initState();

    // load group details
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => loadGroup());
  }

  void loadGroup() async {
    // load group
    await sc
        .getDoc(collectionName: 'groups', docId: widget.grpShort.keys.first)
        .then((aw.Document doc) {
      // update group
      setState(() {
        group = Group.fromDoc(doc);
        loadingGroup = false;
      });
    });
  }

  void _requestJoin() async =>
      // send join requests

      await sc.updateDoc(
          collectionName: 'groups',
          docId: widget.grpShort.keys.first,
          data: {
            'requestIds': group.requests! + [sc.username.value]
          }).then((aw.Document doc) {
        // update group
        setState(() {
          group = Group.fromDoc(doc);
        });
      });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                group.logo != null
                    ? ImagePath(
                        bucket: 'group_logos',
                        imageId: group.logo!,
                        isCircular: true,
                        size: 60)
                    : Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                            color: htSolid2, shape: BoxShape.circle),
                        child:
                            const Icon(Icons.group, size: 40, color: htSolid5),
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${group.members?.length} Members',
                        style: defaultTextStyle.copyWith(fontSize: 12),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 230,
                        child: Text(
                          group.name,
                          overflow: TextOverflow.ellipsis,
                          style: defaultTextStyle.copyWith(fontSize: 18),
                        ),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getGroupTags),
                    ],
                  ),
                ),
              ],
            ),
            loadingGroup
                ? const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 1),
                  )
                : !group.members!.contains(sc.username.value)
                    ? !group.requests!.contains(sc.username.value)
                        ? InterfaceButton(
                            label: 'Request Join',
                            onPressed: _requestJoin,
                          )
                        : Text(
                            'Requested',
                            style: defaultTextStyle.copyWith(fontSize: 18),
                          )
                    : Text(
                        'Member',
                        style: defaultTextStyle.copyWith(fontSize: 18),
                      )
          ],
        ),
      ),
    );
  }

  List<Widget> get getGroupTags {
    List<Row> tags = [];
    for (String tg in widget.grpShort[widget.grpShort.keys.first].keys) {
      // compare with other tags

      tags.add(Row(
        children: [
          Text(
            '#$tg',
            style: defaultTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ));
    }
    return tags;
  }
}

class RoamCard extends StatelessWidget {
  const RoamCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const RoamPage()),
      child: Card(
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 200,
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Lottie.asset(
                'assets/lottie/82445-travelers-walking-using-travelrmap-application.json',
                repeat: true,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.0, -1.0),
                    end: Alignment(0.0, 1.0),
                    colors: [
                      Colors.white10,
                      Colors.white60,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 30,
                  bottom: 6,
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#RoamAbout',
                      style: defaultTextStyle.copyWith(
                        fontSize: 25,
                        height: 1.2,
                        color: htSolid5,
                      ),
                    ),
                    const Text(
                      'Navigate tags of interest and join conversations with respective parties!',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: htSolid3,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
