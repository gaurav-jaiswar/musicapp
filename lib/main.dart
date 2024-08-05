// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music1/fetch.dart';
import 'package:music1/global.dart';
import 'package:music1/player.dart';
import 'package:music1/listview.dart';
import 'package:music1/playlist.dart';
import 'package:music1/searchbar.dart';

GetList mylist = GetList();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  mylist.getfiles();
  initListeners();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music',
      // theme: ThemeData(
      //     scaffoldBackgroundColor: const Color(0xFF352448),
      //     brightness: Brightness.dark,
      //     useMaterial3: true,
      //     textTheme: const TextTheme().copyWith(
      //         titleSmall: const TextStyle(fontWeight: FontWeight.w300),
      //         bodyLarge: const TextStyle(fontWeight: FontWeight.w300))),
      theme: ThemeData.dark().copyWith(
          textTheme: const TextTheme().copyWith(
              titleSmall: const TextStyle(fontWeight: FontWeight.w300),
              bodyLarge: const TextStyle(fontWeight: FontWeight.w300))),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    FAB = const MyFAB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 30,
        titleTextStyle: const TextStyle(fontSize: 30, color: Colors.white),
        backgroundColor: Colors.transparent,
        title: const Text("MUSIC"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MySearchbar(),
                    ));
              },
              icon: const Icon(Icons.search)),
          PopupMenuButton(
            constraints: const BoxConstraints(maxWidth: 133),
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Find Local Songs'),
                onTap: () async {
                  mylist.getfiles(forced: true);
                },
              ),
              PopupMenuItem(
                child: const Text('Sort By'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const SimpleDialog(
                          title: Text("Sort By"),
                          children: [
                            SorterTile(
                              sm: 1,
                              name: 'Song Name',
                            ),
                            SorterTile(sm: 4, name: 'Date Added'),
                          ],
                        );
                      });
                },
              ),
              // PopupMenuItem(
              //   child: const Text('Settings'),
              //   onTap: () {},
              // ),
            ],
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DefaultTabController(
              length: 4,
              child: Expanded(
                child: Column(
                  children: [
                    TabBar(
                      tabs: <Widget>[
                        texttab("Songs"),
                        texttab("Albums"),
                        texttab("Artists"),
                        texttab("Playlists")
                      ],
                    ),
                    Expanded(
                        child: TabBarView(children: <Widget>[
                      Scaffold(
                        body: ValueListenableBuilder(
                            valueListenable: s,
                            builder: (context, snapshot, child) {
                              sorter(list: s.value, mode: sortMode);
                              if (snapshot.isEmpty) {
                                return const Center(
                                  child: Text("No files Found"),
                                );
                              } else {
                                return ScrollList(sa: s.value);
                              }
                            }),
                      ),
                      Scaffold(
                          body: MyListView(
                        mylist: albums,
                      )),
                      Scaffold(
                          body: MyListView(
                        mylist: artists,
                      )),
                      ValueListenableBuilder(
                        valueListenable: playlistNames,
                        builder: (context, playlist, child) => Scaffold(
                            appBar: AppBar(
                              backgroundColor: Colors.transparent,
                              titleTextStyle: const TextStyle(
                                  fontSize: 15, color: Colors.white54),
                              title: Text('${playlist.length} Playlists'),
                              actions: [
                                IconButton(
                                    onPressed: () {
                                      addPlaylist(context);
                                    },
                                    icon: const Icon(Icons.add))
                              ],
                            ),
                            body: PlayListView(
                              mylist: playlist,
                            )),
                      ),
                    ])),
                  ],
                ),
              )),
        ],
      ),
      floatingActionButton: FAB,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ignore: non_constant_identifier_names
Widget? FAB;

//Main tree ends here//
class MyFAB extends StatelessWidget {
  const MyFAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) =>
          details.velocity.pixelsPerSecond.dx > 0 ? playNext() : playPrevious(),
      child: FloatingActionButton.extended(
        extendedPadding: const EdgeInsets.only(left: 10),
        onPressed: () => Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PlayerScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(
                      Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
                  child: child,
                );
              },
            )),
        label: ValueListenableBuilder(
            valueListenable: currentIndex,
            builder: (context, value, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<Image?>(
                        future: getImg(),
                        builder: (context, snapshot) => Container(
                              height: 50,
                              width: 50,
                              clipBehavior: Clip.hardEdge,
                              padding:
                                  EdgeInsets.all(snapshot.data == null ? 2 : 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(212, 175, 4, 118),
                              ),
                              child: snapshot.data ??
                                  Image.asset(
                                    'images/1.png',
                                  ),
                            )),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 50,
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                          minWidth: MediaQuery.of(context).size.width * 0.5),
                      // height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value == null
                                  ? "No Song Selected"
                                  : activeList[value].split('`')[1].trim(),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                              maxLines: 1,
                            ),
                            Text(
                              value == null
                                  ? "No Song Selected"
                                  : "${activeList[value].split('`')[2].trim()} - ${activeList[value].split('`')[3].trim()}",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder(
                        stream: position,
                        builder: (context, snapshot) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                backgroundColor: Colors.white24,
                                value: (player.duration == null ||
                                        snapshot.data == null)
                                    ? 0
                                    : (snapshot.data!.inSeconds /
                                        player.duration!.inSeconds),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (currentIndex.value != null) {
                                      if (player.playing) {
                                        player.pause();
                                      } else {
                                        player.play();
                                      }
                                    }
                                  },
                                  icon: (player.playing)
                                      ? const Icon(Icons.pause_rounded)
                                      : const Icon(Icons.play_arrow_rounded)),
                            ],
                          );
                        }),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        playNext();
                      },
                    )
                  ],
                )),
      ),
    );
  }
}

class SorterTile extends StatelessWidget {
  const SorterTile({
    super.key,
    required this.sm,
    required this.name,
  });
  final int sm;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing:
          Icon(sortMode == sm ? Icons.check_circle : Icons.circle_outlined),
      onTap: () {
        sortMode = sm;
        sorter(list: s.value, mode: sm);
        if (currentIndex.value != null) {
          currentIndex.value = s.value.indexOf(activeList[currentIndex.value!]);
        }
        sorter(list: nsList, mode: sm);
        s.notifyListeners();
        pref!.setInt('sortMode', sm);
        Navigator.of(context).pop();
      },
    );
  }
}

class MyListView extends StatelessWidget {
  const MyListView({
    super.key,
    required this.mylist,
  });
  final List<String> mylist;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mylist.length,
      itemBuilder: (context, index) {
        return (ListTile(
          title: Text(
            mylist[index],
            softWrap: true,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          tileColor: Colors.transparent,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayListScreen(
                    name: mylist[index],
                    purpose: mylist == artists
                        ? 2
                        : mylist == albums
                            ? 3
                            : 0,
                  ),
                ));
          },
        ));
      },
    );
  }
}

class ScrollList extends StatelessWidget {
  const ScrollList({
    super.key,
    required this.sa,
  });

  final List<String> sa;

  @override
  Widget build(BuildContext context) {
    ScrollController sc = ScrollController();
    return Scrollbar(
      controller: sc,
      interactive: true,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(8),
      child: ListView.builder(
        controller: sc,
        itemCount: sa.length,
        itemBuilder: (context, index) {
          return (MainListTile(
            sa: sa[index],
            ontap: () {
              if (shuffle) {
                activeList = sList;
                sList.shuffle();
                currentIndex.value = sList.indexOf(sa[index]);
                player.setAudioSource(AudioSource.file(
                    sList[currentIndex.value!].split('`')[0].trim()));
                player.play();
                saveIndex();
              } else {
                activeList = nsList;
                sorter(list: nsList, mode: sortMode);
                currentIndex.value = index;
                player.setAudioSource(
                    AudioSource.file(nsList[index].split('`')[0].trim()));
                player.play();
                saveIndex();
              }
              s.notifyListeners();
            },
          ));
        },
      ),
    );
  }
}

class MainListTile extends StatelessWidget {
  const MainListTile({
    super.key,
    required this.sa,
    required this.ontap,
  });

  final String sa;
  final void Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      trailing: IconButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  ListTile(
                    title: Text(sa.split('`')[2].trim()),
                    leading: const Icon(Icons.person_outlined),
                  ),
                  ListTile(
                      title: Text(sa.split('`')[3].trim()),
                      leading: const Icon(Icons.album_outlined)),
                  ListTile(
                    title: const Text('Play Next'),
                    leading: const Icon(Icons.skip_next_outlined),
                    onTap: () {
                      nextOffset = 0;
                      addNext(sa);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text('Add To Queue'),
                    leading: const Icon(Icons.queue_music_outlined),
                    onTap: () {
                      addNext(sa);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text('Add To Playlist'),
                    leading: const Icon(Icons.playlist_add_outlined),
                    onTap: () {
                      Navigator.of(context).pop();
                      addToPlayListModalSheet(context, sa);
                    },
                  )
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.more_vert),
        color: Colors.white54,
      ),
      contentPadding: const EdgeInsets.only(left: 16),
      title: Text(
        sa.split('`')[1].trim(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: currentIndex.value != null &&
                    (sa == activeList[currentIndex.value!])
                ? Colors.redAccent
                : Colors.white),
        maxLines: 1,
      ),
      subtitle: Text(
        "${sa.split('`')[2].trim()} - ${sa.split('`')[3].trim()}",
        softWrap: true,
        maxLines: 1,
        style: const TextStyle(fontSize: 11, color: Colors.white60),
      ),
      tileColor: Colors.transparent,
      onTap: ontap,
    );
  }
}

Tab texttab(String name) {
  return (Tab(
    text: name,
  ));
}

void addToPlayListModalSheet(BuildContext context, String toAdd) {
  showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
            padding: const EdgeInsets.only(top: 15, left: 15),
            itemCount: playlistNames.value.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.playlist_add_check),
              title: Text(playlistNames.value[index]),
              onTap: () {
                plists[index] = '${plists[index]}``$toAdd';
                pref!.setStringList('plists', plists);
                Navigator.of(context).pop();
              },
            ),
          ));
}




//OnTAP for main list tile

