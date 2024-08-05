// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music1/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool shuffle = false, loop = false;

List<String> albums = [];
List<String> artists = [];
List<String> sList = [];
List<String> nsList = [];
List<String> plists = [""];
List<String> favourites = [];
ValueNotifier<List<String>> playlistNames = ValueNotifier(["Favourites"]);
List<String> activeList = nsList;
int sortMode = 1;
SharedPreferences? pref;
final player = AudioPlayer();
Stream position = player.positionStream;
ValueNotifier<bool> isPlaying = ValueNotifier(false);
ValueNotifier<int?> currentIndex = ValueNotifier(null);
ValueNotifier<List<String>> s = ValueNotifier([]);
int nextOffset = 0;

void getAlbums() {
  albums.clear();
  for (String item in s.value) {
    if (!albums.contains(item.split('`')[3].trim())) {
      albums.add(item.split('`')[3].trim());
    }
  }
  albums.sort((a, b) => a.compareTo(b));
  albums.sort(((a, b) => a.compareTo(b)));
  if (albums.isNotEmpty) {
    albums.removeAt(0);
  }
}

void getArtists() {
  artists.clear();
  for (String item in s.value) {
    if (!artists.contains(item.split('`')[2].trim())) {
      artists.add(item.split('`')[2].trim());
    }
  }
  artists.sort((a, b) => a.compareTo(b));
  artists.sort(((a, b) => a.compareTo(b)));
  if (artists.isNotEmpty) {
    artists.removeAt(0);
  }
}

void saveIndex() async {
  await pref!.remove('index');
  if (currentIndex.value != null) {
    pref!.setString('index', activeList[currentIndex.value!]);
  }
}
//s.value.indexOf(activeList[currentIndex.value!])

void readIndexAndPList() async {
  shuffle = pref!.getBool('shuffle') ?? false;
  loop = pref!.getBool('loop') ?? false;
  activeList =
      shuffle ? sList : nsList; //To change after playlistNames implementation
  String? a = pref!.getString('index');
  currentIndex.value = a != null ? activeList.indexOf(a) : null;
  if (currentIndex.value != null) {
    player.setAudioSource(
        AudioSource.file(activeList[currentIndex.value!].split('`')[0].trim()));
  }
  playlistNames.value = pref!.getStringList('playlistNames') ?? ['Favourites'];
  favourites = pref!.getStringList('favourites') ?? [];
  plists = pref!.getStringList('plists') ?? [''];
}

void sorter({required List<String> list, required int mode}) {
  if (mode == 4) {
    list.sort((a, b) =>
        b.split('`')[mode].trim().compareTo(a.split('`')[mode].trim()));
  } else {
    list.sort((a, b) =>
        a.split('`')[mode].trim().compareTo(b.split('`')[mode].trim()));
  }
}

void writeShuffle() {
  pref!.setBool('shuffle', shuffle);
}

void addNext(String name) {
  if (currentIndex.value != null) {
    String current = activeList[currentIndex.value!];
    nextOffset++;
    activeList.removeWhere((element) => element == name);
    currentIndex.value = activeList.indexOf(current);
    activeList.insert(currentIndex.value! + nextOffset, name);
  }
}

void addPlaylist(BuildContext context) {
  String name = '';
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Playlist Name"),
            onChanged: (value) {
              name = value;
            },
            onSubmitted: (value) {
              if (value != '') {
                playlistNames.value.add(value);
                plists.add('');
                pref!.remove('playlistNames');
                pref!.setStringList('playlistNames', playlistNames.value);
                Navigator.of(context).pop();
                playlistNames.notifyListeners();
              }
            },
          ),
        ),
        MaterialButton(
          onPressed: () {
            if (name != '') {
              playlistNames.value.add(name);
              plists.add('');
              pref!.remove('playlistNames');
              pref!.setStringList('playlistNames', playlistNames.value);
            }
            Navigator.of(context).pop();
            playlistNames.notifyListeners();
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          minWidth: 100,
          color: Colors.white,
          textColor: Colors.black,
          child: const Text("Add"),
        )
      ],
    ),
  );
}

void savePlayList(String playlistName, List<String> playlist) {
  String newList = '';
  for (String item in playlist) {
    newList = "$newList``$item";
  }
  plists[playlistNames.value.indexOf(playlistName)] = newList;
  pref!.setStringList('plists', plists);
}

Future<Image?> getImg() async {
  if (currentIndex.value != null) {
    Metadata metadata = await MetadataRetriever.fromFile(
        File(activeList[currentIndex.value!].split('`')[0].trim()));
    if (metadata.albumArt != null) {
      return Image.memory(
        metadata.albumArt!,
        fit: BoxFit.cover,
      );
    } else {
      return null;
    }
  }
  return null;
}

void initListeners() {
  player.playingStream.listen((event) {
    isPlaying.value = event;
  });
  position.listen((event) {
    if ((player.duration != null) &&
        (event.inSeconds == player.duration!.inSeconds)) {
      if (loop) {
        player.seek(Duration.zero);
      } else {
        playNext();
      }
    }
  });
  isPlaying.addListener(() {
    if (isPlaying.value) {
      //start service
    } else {
      //stop service
    }
  });
}
