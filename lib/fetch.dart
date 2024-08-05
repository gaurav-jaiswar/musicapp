// ignore_for_file: division_optimization, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, use_build_context_synchronously

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music1/global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetList {
  List<FileSystemEntity> files = [];
  List<Directory>? dir = [];
  List<String> titles = [];
  Metadata? metadata;
  bool busy = false;

  void getfiles({bool forced = false}) async {
    pref = await SharedPreferences.getInstance();
    await readData();

    if ((titles.isEmpty || forced) && !busy) {
      Fluttertoast.showToast(msg: "Searching Songs...");
      busy = true;
      bool a = false;
      var info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt < 33) {
        a = await Permission.storage.isGranted;
        if (!a) {
          await Permission.storage.request();
          a = await Permission.storage.isGranted;
        }
      } else {
        a = await Permission.audio.isGranted;
        if (!a) {
          await Permission.audio.request();
          a = await Permission.storage.isGranted;
        }
      }
      if (a) {
        files.clear();
        List<Directory>? dir = await getExternalStorageDirectories();
        for (Directory item in dir!) {
          item = Directory(item.path.split("/Android").first);
          files.addAll(
              await item.list(recursive: false, followLinks: false).toList());
        }
        files.removeWhere((element) => element.path.endsWith("/Android"));

        dir.clear();
        for (FileSystemEntity item in files) {
          if (item is Directory) {
            dir.add(Directory(item.path));
          }
        }
        files.clear();
        for (Directory item in dir) {
          files.addAll(item.listSync(recursive: true, followLinks: false));
        }
        titles.clear();
        for (FileSystemEntity temp in files) {
          if (temp.path.endsWith(".mp3")) {
            metadata = await MetadataRetriever.fromFile(File(temp.path));
            // String title =
            //     "${temp.path},${metadata!.trackName ?? temp.path.split('/').last.split('.mp3').first},${temp.statSync().modified.toString().replaceAll('-', '')}";
            titles.add(
                "${temp.path}`${metadata!.trackName ?? temp.path.split('/').last.split('.mp3').first}`${metadata!.trackArtistNames == null ? 'Unknown' : metadata!.trackArtistNames.toString().replaceAll('[', '').replaceAll(']', '')}`${metadata!.albumName ?? 'Unknown'}`${temp.statSync().modified.toString().replaceAll('-', '')}");
          }
        }
        writeData();
      }
      busy = false;
      Fluttertoast.showToast(
        msg: "${titles.length} Songs Found!",
      );
    }
    s.value = titles;
    sortMode = pref!.getInt('sortMode') ?? 1;
    sorter(list: s.value, mode: sortMode);
    sList.clear();
    nsList.clear();
    sList.addAll(titles);
    sList.shuffle();
    s.notifyListeners();
    nsList.addAll(s.value);
    //sorter(list: nsList, mode: sortMode);
    readIndexAndPList();
    getAlbums();
    getArtists();
  } //END OF GETFILES()

  void writeData() async {
    await pref!.remove('list');
    await pref!.setStringList("list", titles);
  }

  Future<void> readData() async {
    var temp = pref!.getStringList("list");
    if (temp != null) {
      titles = temp;
    }
  }
}
