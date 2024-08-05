import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music1/main.dart';
import 'global.dart';

class PlayListScreen extends StatelessWidget {
  const PlayListScreen({super.key, required this.name, this.purpose = 0});
  final String name;
  final int purpose;

  @override
  Widget build(BuildContext context) {
    List<String> dummy = [];
    if (purpose == 2) {
      for (String item in s.value) {
        if (name == item.split('`')[purpose].trim()) {
          dummy.add(item);
        }
      }
      sorter(list: dummy, mode: 1);
    }
    if (purpose == 3) {
      for (String item in s.value) {
        if (name == item.split('`')[purpose].trim()) {
          dummy.add(item);
        }
      }
      sorter(list: dummy, mode: 1);
    }
    return Scaffold(
      floatingActionButton: FAB,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: dummy.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            dummy[index].split('`')[1].trim(),
            softWrap: true,
            style: TextStyle(
                color: currentIndex.value != null &&
                        (dummy[index] == activeList[currentIndex.value!])
                    ? Colors.redAccent
                    : Colors.white),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          tileColor: Colors.transparent,
          onTap: () {
            activeList = dummy;
            currentIndex.value = index;
            player.setAudioSource(
                AudioSource.file(dummy[index].split('`')[0].trim()));
            player.play();
          },
        ),
      ),
    );
  }
}
