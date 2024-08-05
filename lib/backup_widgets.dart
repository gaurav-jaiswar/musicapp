//oppo style current playing//

// StreamBuilder<Duration?>(
          //   stream: player.positionStream,
          //   builder: (context, snapshot) => LinearProgressIndicator(
          //     value: (player.duration == null || snapshot.data == null)
          //         ? 0
          //         : (snapshot.data!.inSeconds / player.duration!.inSeconds),
          //     valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          //   ),
          // ),


// ValueListenableBuilder(
          //   valueListenable: currentIndex,
          //   builder: (context, value, child) => ListTile(
          //     title: Text(
          //       value == null
          //           ? "No Song Selected"
          //           : activeList[value].split('`')[1].trim(),
          //       softWrap: true,
          //       style: const TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w400,
          //           color: Colors.white),
          //       maxLines: 1,
          //     ),
          //     subtitle: Text(
          //       value == null
          //           ? "No Song Selected"
          //           : "${activeList[value].split('`')[2].trim()} - ${activeList[value].split('`')[3].trim()}",
          //       softWrap: true,
          //       maxLines: 1,
          //       style: const TextStyle(fontSize: 11, color: Colors.white60),
          //     ),
          //     tileColor: Colors.transparent,
          //     onTap: () => Navigator.push(
          //         context,
          //         PageRouteBuilder(
          //           opaque: false,
          //           pageBuilder: (context, animation, secondaryAnimation) =>
          //               const PlayerScreen(),
          //           transitionsBuilder:
          //               (context, animation, secondaryAnimation, child) {
          //             return SlideTransition(
          //               position: animation.drive(Tween(
          //                   begin: const Offset(0.0, 1.0), end: Offset.zero)),
          //               child: child,
          //             );
          //           },
          //         )),
          //     leading: FutureBuilder<Image?>(
          //         future: getImg(),
          //         builder: (context, snapshot) => Container(
          //               clipBehavior: Clip.hardEdge,
          //               padding: EdgeInsets.all(snapshot.data == null ? 2 : 0),
          //               decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(20),
          //                 color: const Color.fromARGB(212, 175, 4, 118),
          //               ),
          //               child: snapshot.data ??
          //                   Image.asset(
          //                     'images/1.png',
          //                   ),
          //             )),
          //     trailing: Wrap(
          //       direction: Axis.horizontal,
          //       alignment: WrapAlignment.end,
          //       // mainAxisSize: MainAxisSize.min,
          //       children: [
          //         StreamBuilder(
          //             stream: player.playingStream,
          //             builder: (context, snapshot) {
          //               return IconButton(
          //                   onPressed: () {
          //                     if (currentIndex.value != null) {
          //                       if (snapshot.data != null && snapshot.data!) {
          //                         player.pause();
          //                       } else {
          //                         player.play();
          //                       }
          //                     }
          //                   },
          //                   icon: (snapshot.data != null && snapshot.data!)
          //                       ? const Icon(Icons.pause_rounded)
          //                       : const Icon(Icons.play_arrow_rounded));
          //             }),
          //         IconButton(
          //           icon: const Icon(Icons.skip_next),
          //           onPressed: () {
          //             playNext();
          //           },
          //         )
          //       ],
          //     ),
          //   ),
          // ),

          
//Back to lastplayed playlist
