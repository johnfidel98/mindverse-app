import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:get/get.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';

class MVSearchController extends GetxController {
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
      for (aw.Document doc in res.documents) {
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
        for (aw.Document doc in res.documents) {
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

  void processSearch({required aw.DocumentList result, bool isTag = false}) {
    for (aw.Document doc in result.documents) {
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
      Query.search('name', q),
      Query.orderDesc('\$createdAt'),
      Query.limit(10),
    ]).then((res) => processSearch(result: res));

    // search profile username
    await ses.getDocs(collectionName: 'profiles', queries: [
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
