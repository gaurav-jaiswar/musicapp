// ignore_for_file: division_optimization, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music1/global.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: const Scaffold(
        backgroundColor: Colors.black45,
      ),
      key: const Key("PlayerScreen"),
      direction: DismissDirection.down,
      onDismissed: (direction) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: IconButton(
            iconSize: 30,
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 00, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder(
                  valueListenable: currentIndex,
                  builder: (context, value, child) {
                    String fileName = value == null
                        ? "Unknown"
                        : activeList[value].split('`')[1].trim();
                    _controller.reset();
                    _controller.forward();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 28,
                          child: fileName.length > 30
                              ? Marquee(
                                  numberOfRounds: 1,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  text: fileName,
                                  blankSpace: 20,
                                  style: const TextStyle(fontSize: 20),
                                  fadingEdgeEndFraction: .02,
                                )
                              : Text(
                                  fileName,
                                  style: const TextStyle(fontSize: 20),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 1.5, bottom: 15),
                          child: Text(
                            value == null
                                ? "Unknown"
                                : activeList[value].split('`')[2].trim(),
                            style: const TextStyle(color: Colors.white38),
                            softWrap: true,
                            maxLines: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder(
                                future: getImg(),
                                builder: (context, snapshot) => Container(
                                    clipBehavior: Clip.hardEdge,
                                    padding: EdgeInsets.all(
                                        snapshot.data == null ? 20 : 0),
                                    height: 300,
                                    width: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          212, 175, 4, 118),
                                    ),
                                    child: ScaleTransition(
                                      scale: _animation,
                                      child: snapshot.data ??
                                          Image.asset(
                                            'images/1.png',
                                          ),
                                    ))),
                          ],
                        ),
                      ],
                    );
                  }),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: shuffle ? Colors.red : Colors.white70,
                    ),
                    onPressed: () {
                      if (shuffle) {
                        shuffle = false;
                        activeList = nsList;
                        writeShuffle();
                        if (currentIndex.value != null) {
                          currentIndex.value =
                              nsList.indexOf(sList[currentIndex.value!]);
                        }
                      } else {
                        shuffle = true;
                        sList.shuffle();
                        activeList = sList;
                        writeShuffle();
                        if (currentIndex.value != null) {
                          currentIndex.value =
                              sList.indexOf(nsList[currentIndex.value!]);
                        }
                      }
                      setState(() {});
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: currentIndex,
                    builder: (context, value, child) {
                      bool isFavourite = value == null
                          ? false
                          : favourites.contains(activeList[value]);
                      return IconButton(
                          onPressed: () {
                            setState(() {
                              if (isFavourite) {
                                favourites.removeWhere(
                                    (element) => element == activeList[value]);
                                pref!.setStringList('favourites', favourites);
                              } else {
                                if (value != null) {
                                  favourites.add(activeList[value]);
                                  pref!.setStringList('favourites', favourites);
                                }
                              }
                            });
                          },
                          icon: isFavourite
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(Icons.favorite_border));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.loop),
                    color: loop ? Colors.red : Colors.white70,
                    onPressed: () {
                      loop = !loop;
                      pref!.setBool('loop', loop);
                      setState(() {});
                    },
                  ),
                ],
              ),
              StreamBuilder(
                  stream: position,
                  builder: (context, snapshot) => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  snapshot.data == null
                                      ? "00:00"
                                      : "${(snapshot.data!.inSeconds / 60).toInt().toString().padLeft(2, "0")}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, "0")}",
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  player.duration == null
                                      ? "00:00"
                                      : "${(player.duration!.inSeconds / 60).toInt().toString().padLeft(2, "0")}:${(player.duration!.inSeconds % 60).toString().padLeft(2, "0")}",
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          SliderTheme(
                            data: const SliderThemeData(
                                overlayColor: Colors.white,
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 10),
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 0)),
                            child: Slider(
                              min: 0,
                              max: player.duration == null
                                  ? double.infinity
                                  : player.duration!.inSeconds.toDouble(),
                              value: snapshot.data == null
                                  ? 0
                                  : snapshot.data!.inSeconds.toDouble(),
                              onChanged: (value) {
                                player.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                        ],
                      )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      playPrevious();
                    },
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 40,
                  ),
                  ValueListenableBuilder(
                    valueListenable: isPlaying,
                    builder: (context, playing, child) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: IconButton(
                          iconSize: 70,
                          color: Colors.white,
                          onPressed: () {
                            if (currentIndex.value != null) {
                              if (playing) {
                                player.pause();
                              } else {
                                player.play();
                              }
                            }
                          },
                          icon: playing
                              ? const Icon(Icons.pause_rounded)
                              : const Icon(Icons.play_arrow_rounded)),
                    ),
                  ),
                  IconButton(
                      iconSize: 40,
                      onPressed: () {
                        playNext();
                      },
                      icon: const Icon(Icons.skip_next_rounded)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void playNext() {
  if (currentIndex.value != null) {
    if (currentIndex.value! < activeList.length - 1) {
      player.setAudioSource(AudioSource.file(
          activeList[currentIndex.value! + 1].split('`')[0].trim()));
      currentIndex.value = currentIndex.value! + 1;
      player.play();
      saveIndex();
      s.notifyListeners();
      if (nextOffset > 0) {
        nextOffset--;
      }
    } else {
      player
          .setAudioSource(AudioSource.file(activeList[0].split('`')[0].trim()));
      currentIndex.value = 0;
      player.play();
      saveIndex();
      s.notifyListeners();
    }
  }
}

void playPrevious() {
  if (currentIndex.value != null) {
    if (player.position.inSeconds > 10) {
      player.seek(Duration.zero);
    } else {
      if (currentIndex.value! > 0) {
        player.setAudioSource(AudioSource.file(
            activeList[currentIndex.value! - 1].split('`')[0].trim()));
        currentIndex.value = currentIndex.value! - 1;
        player.play();
        saveIndex();
        s.notifyListeners();
        if (nextOffset > 0) {
          nextOffset++;
        }
      } else {
        player.setAudioSource(
            AudioSource.file(activeList.last.split('`')[0].trim()));
        currentIndex.value = activeList.length - 1;
        player.play();
        saveIndex();
        s.notifyListeners();
      }
    }
  }
}
