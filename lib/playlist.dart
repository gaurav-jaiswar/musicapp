import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music1/global.dart';
import 'package:music1/main.dart';

class PlayListView extends StatelessWidget {
  const PlayListView({
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
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              String playlistname = mylist[index];
              List<String> playlist = [];
              if (index == 0) {
                playlist = favourites;
              } else {
                playlist = plists[index].split('``');
                playlist.removeAt(0);
              }
              return Scaffold(
                  //editing from here
                  floatingActionButton: FAB,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  appBar: AppBar(
                    title: Text(playlistname),
                    backgroundColor: Colors.transparent,
                  ),
                  body: ReorderList(playlistIndex: index, playlist: playlist));
            }));
          },
          trailing: index == 0
              ? null
              : IconButton(
                  icon: const Icon(Icons.delete_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Playlist?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                playlistNames.value.removeAt(index);
                                plists.removeAt(index);
                                pref!.remove('playlistNames');
                                pref!.remove('plists');
                                pref!.setStringList(
                                    'playlistNames', playlistNames.value);
                                pref!.setStringList('plists', plists);
                                Navigator.of(context).pop();
                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                playlistNames.notifyListeners();
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.red),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'No',
                              ))
                        ],
                      ),
                    );
                  },
                ),
        ));
      },
    );
  }
}

class ReorderList extends StatefulWidget {
  const ReorderList({
    super.key,
    required this.playlist,
    required this.playlistIndex,
  });

  final List<String> playlist;
  final int playlistIndex;

  @override
  State<ReorderList> createState() => _ReorderListState();
}

class _ReorderListState extends State<ReorderList> {
  @override
  void dispose() {
    savePlayList(playlistNames.value[widget.playlistIndex], widget.playlist);
    super.dispose();
  }

  void remove(int index) {
    setState(() {
      widget.playlist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemBuilder: (context, index) => ListTile(
        key: Key('$index'),
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(
          widget.playlist[index].split('`')[1].trim(),
          softWrap: true,
          style: TextStyle(
              color: currentIndex.value != null &&
                      (widget.playlist[index] ==
                          activeList[currentIndex.value!])
                  ? Colors.redAccent
                  : Colors.white),
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
        tileColor: Colors.transparent,
        onTap: () {
          setState(() {
            activeList = widget.playlist;
            currentIndex.value = index;
            player.setAudioSource(
                AudioSource.file(widget.playlist[index].split('`')[0].trim()));
            player.play();
          });
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => remove(index),
        ),
      ),
      itemCount: widget.playlist.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          if (currentIndex.value != null) {
            String current = activeList[currentIndex.value!];
            String temp = widget.playlist.removeAt(oldIndex);
            widget.playlist.insert(newIndex, temp);
            currentIndex.value = activeList.indexOf(current);
          } else {
            widget.playlist
                .insert(newIndex, widget.playlist.removeAt(oldIndex));
          }
        });
      },
    );
  }
}
