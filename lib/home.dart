import 'package:flutter/material.dart';
import 'package:flutter_application_1/tik_tok_icons_icons.dart';
import 'package:flutter_application_1/videoUpload/video_background_upload.dart';
import 'package:flutter_application_1/widgets/bottom_toolbar.dart';
import 'package:flutter_application_1/widgets/video_description.dart';
import 'package:video_player/video_player.dart';

import 'widgets/actions_toolbar.dart';

class Home extends StatefulWidget {
  static const double navigationIconSize = 20.0;
  static const double createButtonWidth = 38.0;
  const Home({key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  VideoPlayerController controller;

  String imageUrl = "";

  Widget get customCreateIcon => SizedBox(
      width: 45.0,
      height: 27.0,
      child: Stack(children: [
        Container(
            margin: const EdgeInsets.only(left: 10.0),
            width: BottomToolbar.CreateButtonWidth,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 250, 45, 108),
                borderRadius: BorderRadius.circular(7.0))),
        Container(
            margin: const EdgeInsets.only(right: 10.0),
            width: BottomToolbar.CreateButtonWidth,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 32, 211, 234),
                borderRadius: BorderRadius.circular(7.0))),
        Center(
            child: Container(
          height: double.infinity,
          width: BottomToolbar.CreateButtonWidth,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(7.0)),
          child: const Icon(
            Icons.add,
            size: 20.0,
          ),
        )),
      ]));

  @override
  void initState() {
    controller = VideoPlayerController.asset('assets/thet.mp4')
      ..initialize().then((_) {
        setState(() {
          controller.play();
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  Widget get topSection => Container(
        height: 100.0,
        padding: const EdgeInsets.only(bottom: 15.0),
        alignment: const Alignment(0.0, 1.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Following'),
              Container(
                width: 15.0,
              ),
              const Text('For you',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold))
            ]),
      );

  Widget get middleSection => Expanded(
      child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[VideoPlayerScreen(), ActionsToolbar()]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: VideoPlayer(controller)),
          Center(
            // ignore: sized_box_for_whitespace
            child: Container(
              width: 500,
              height: 500,
              child: IconButton(
                  iconSize: 70,
                  color: Colors.red,
                  onPressed: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }

                    setState(() {});
                  },
                  icon: Icon(controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow)),
            ),
          ),
          Column(
            children: <Widget>[
              // Top section
              topSection,

              // Middle expanded
              middleSection,

              // Bottom Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(TikTokIcons.home,
                      color: Colors.white,
                      size: BottomToolbar.NavigationIconSize),
                  const Icon(TikTokIcons.search,
                      color: Colors.white,
                      size: BottomToolbar.NavigationIconSize),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const VideoBackgroundHandler(),
                        ));
                      },
                      child: Container(child: customCreateIcon)),
                  const Icon(TikTokIcons.messages,
                      color: Colors.white,
                      size: BottomToolbar.NavigationIconSize),
                  const Icon(TikTokIcons.profile,
                      color: Colors.white,
                      size: BottomToolbar.NavigationIconSize)
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


}
