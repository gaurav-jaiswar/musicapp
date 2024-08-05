import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music1/global.dart';
import 'package:music1/main.dart';

class MySearchbar extends StatefulWidget {
  const MySearchbar({super.key});

  @override
  State<MySearchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<MySearchbar> {
  List<String> songResult = [];
  // List<String> albumResult = [];
  // List<String> artistResult = [];
  String query = '';
  void changed(String newQuery) {
    setState(() {
      if (newQuery != '') {
        query = newQuery.toLowerCase();
        songResult = s.value
            .where((element) =>
                element.split('`')[1].trim().toLowerCase().contains(query))
            .toList();
        List<String> temp1 = songResult
            .where((element) =>
                element.split('`')[1].trim().toLowerCase().startsWith(query))
            .toList();
        for (String item in songResult) {
          if (!temp1.contains(item)) {
            temp1.add(item);
          }
        }
        songResult = temp1;
        // albumResult = albums
        //     .where((element) => element.toLowerCase().contains(query))
        //     .toList();
        // artistResult = artistResult
        //     .where((element) => element.toLowerCase().contains(query))
        //     .toList();
      } else {
        songResult.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Searchfield(
              onchanged: changed,
            ),
            songResult.isEmpty
                ? const Placeholder(
                    fallbackHeight: 0,
                    fallbackWidth: 0,
                  )
                : Builder(builder: (context) {
                    List<String> temp = [];
                    if (songResult.length > 5) {
                      temp.addAll(songResult.getRange(0, 5));
                    } else {
                      temp = songResult;
                    }
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Songs'),
                            songResult.length > 5
                                ? TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchMoreView(
                                                    result: songResult),
                                          ));
                                    },
                                    child: const Text('More>'))
                                : const Placeholder(
                                    color: Colors.transparent,
                                    fallbackHeight: 48,
                                    fallbackWidth: 10,
                                  ),
                          ],
                        ),
                      ),
                      for (String item in temp)
                        MainListTile(
                            sa: item,
                            ontap: () {
                              setState(() {
                                currentIndex.value = shuffle
                                    ? sList.indexOf(item)
                                    : nsList.indexOf(item);
                                activeList = shuffle ? sList : nsList;
                                player.setAudioSource(AudioSource.file(
                                    item.split('`')[0].trim()));
                                player.play;
                                saveIndex();
                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                s.notifyListeners();
                              });
                            })
                    ]);
                  }),
          ],
        ),
      ),
    );
  }
}

class Searchfield extends StatelessWidget {
  const Searchfield({
    super.key,
    required this.onchanged,
  });
  final void Function(String) onchanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Songs",
          prefixIcon: const Icon(Icons.search_outlined),
          suffixIcon: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.close_outlined,
                color: Colors.red,
              )),
        ),
        onChanged: onchanged,
        autofocus: true,
        maxLines: 1,
      ),
    );
  }
}

class SearchMoreView extends StatefulWidget {
  const SearchMoreView({super.key, required this.result});
  final List<String> result;

  @override
  State<SearchMoreView> createState() => _SearchMoreViewState();
}

class _SearchMoreViewState extends State<SearchMoreView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Search Results",
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.result.length,
        itemBuilder: (context, index) => MainListTile(
            sa: widget.result[index],
            ontap: () {
              setState(() {
                currentIndex.value = shuffle
                    ? sList.indexOf(widget.result[index])
                    : s.value.indexOf(widget.result[index]);
                player.setAudioSource(AudioSource.file(
                    widget.result[index].split('`')[0].trim()));
                player.play;
                saveIndex();
                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                s.notifyListeners();
              });
            }),
      ),
    );
  }
}
