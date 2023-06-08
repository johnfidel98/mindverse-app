import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/components/ad.dart';
import 'package:mindverse/components/avatar.dart';
import 'package:mindverse/components/text.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/search.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/pages/profile.dart';
import 'package:mindverse/utils.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MVSearchController sc = Get.put(MVSearchController());
  final SessionController ses = Get.find<SessionController>();
  final TextEditingController qc = TextEditingController();

  String query = '';

  late Timer _trendsTimer;

  @override
  void initState() {
    super.initState();

    // load trends
    sc.getTrends(ses: ses);

    // get trends every 30 min
    _trendsTimer = Timer.periodic(
        const Duration(minutes: 30), (_) async => await sc.getTrends(ses: ses));

    // listen for query changes
    qc.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // indicate query active
    setState(() {
      query = qc.text;
    });

    // search query
    sc.search(q: qc.text, ses: ses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBack(),
        title: TextField(
          controller: qc,
          onTapOutside: (event) {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          decoration: InputDecoration(
            hintStyle: defaultTextStyle.copyWith(
                fontSize: 20, color: Colors.grey[500]),
            border: InputBorder.none,
            hintText: 'Search...',
            isDense: true,
          ),
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                  onPressed: () => qc.clear(),
                  icon: const Icon(
                    Icons.clear,
                    color: htSolid5,
                    size: 30,
                  )),
            ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: Text(
                query.isNotEmpty ? 'Search Results' : 'Group Suggestions',
                style: const TextStyle(
                    inherit: true, fontSize: 18, color: htSolid3),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(height: 1, color: htSolid5),
            ),
            query.isNotEmpty
                ? Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      itemCount: sc.results.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ResultDisplay(result: sc.results[index]),
                            index % 4 == 0
                                ? const NativeAdvert()
                                : const SizedBox(),
                          ],
                        );
                      },
                    ),
                  )
                : Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      itemCount: sc.trends.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ResultDisplay(result: sc.trends[index]),
                            index % 4 == 0
                                ? const NativeAdvert()
                                : const SizedBox()
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // remove text listener
    qc.removeListener(_onTextChanged);

    // cancel trends timer
    if (_trendsTimer.isActive) {
      _trendsTimer.cancel();
    }

    super.dispose();
  }
}

class ResultDisplay extends StatelessWidget {
  const ResultDisplay({
    super.key,
    required this.result,
  });

  final SearchData result;

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = const TextStyle(
      inherit: true,
      color: htSolid5,
      fontSize: 12,
    );
    return Column(
      children: [
        result.group != null
            ? ListTile(
                title: Text('Group', style: titleStyle),
                leading: SizedBox(
                  width: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: htSolid4),
                    ),
                    child: const Center(
                        child: Text(
                      '#',
                      style: TextStyle(
                        inherit: true,
                        color: htSolid5,
                        fontSize: 30,
                      ),
                    )),
                  ),
                ),
                subtitle: Text(
                  result.group!.name,
                  style: const TextStyle(
                    inherit: true,
                    color: htSolid4,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    height: 1.5,
                  ),
                ),
                minVerticalPadding: 22,
              )
            : ListTile(
                onTap: () => Get.to(ProfilePage(profile: result.profile!)),
                title: Text('Profile', style: titleStyle),
                leading: SizedBox(
                  width: 60,
                  child: AvatarSegment(
                    userProfile: result.profile!,
                    expanded: false,
                    size: 60,
                    isCircular: true,
                  ),
                ),
                subtitle: NamingSegment(
                  owner: result.profile!,
                  size: 22,
                  height: 1.5,
                  fontDiff: 5,
                  rowAlignment: MainAxisAlignment.start,
                ),
                minVerticalPadding: 22,
              ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(height: 0.2, thickness: 0.2, color: htSolid5),
        ),
      ],
    );
  }
}
