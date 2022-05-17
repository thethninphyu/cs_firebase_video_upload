import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../tik_tok_icons_icons.dart';

class BottomToolbar extends StatefulWidget {
  static const double NavigationIconSize = 20.0;
  static const double CreateButtonWidth = 38.0;

  BottomToolbar({Key key}) : super(key: key);

  @override
  State<BottomToolbar> createState() => _BottomToolbarState();
}

class _BottomToolbarState extends State<BottomToolbar> {
  String imageUrl = "";

  Widget get customCreateIcon => Container(
      width: 45.0,
      height: 27.0,
      child: Stack(children: [
        Container(
            margin: EdgeInsets.only(left: 10.0),
            width: BottomToolbar.CreateButtonWidth,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 250, 45, 108),
                borderRadius: BorderRadius.circular(7.0))),
        Container(
            margin: EdgeInsets.only(right: 10.0),
            width: BottomToolbar.CreateButtonWidth,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 32, 211, 234),
                borderRadius: BorderRadius.circular(7.0))),
        Center(
            child: Container(
          height: double.infinity,
          width: BottomToolbar.CreateButtonWidth,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(7.0)),
          child: Icon(
            Icons.add,
            size: 20.0,
          ),
        )),
      ]));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(TikTokIcons.home,
            color: Colors.white, size: BottomToolbar.NavigationIconSize),
        Icon(TikTokIcons.search,
            color: Colors.white, size: BottomToolbar.NavigationIconSize),
        InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => uploadVideo(),
              ));
            },
            child: Container(child: customCreateIcon)),
        Icon(TikTokIcons.messages,
            color: Colors.white, size: BottomToolbar.NavigationIconSize),
        Icon(TikTokIcons.profile,
            color: Colors.white, size: BottomToolbar.NavigationIconSize)
      ],
    );
  }

  uploadVideo() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    XFile video;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      video = (await _imagePicker.pickVideo(source: ImageSource.camera));
      var file = File(video.path);

      if (video != null) {
        //Upload to Firebase
        var snapshot =
            await _firebaseStorage.ref().child('video/videoName').putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }
}
