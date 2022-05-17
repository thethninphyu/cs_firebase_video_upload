// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({Key key}) : super(key: key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Image',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(color: Colors.white),
                  // ignore: prefer_const_literals_to_create_immutables
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 1,
                    ),
                  ],
                ),
                // ignore: unnecessary_null_comparison
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            new CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                      )
                    : VideoPlayer(VideoPlayerController.network('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4')),),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text("Upload Image",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              onPressed: () {
                uploadImage();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue)),
              elevation: 5.0,
              color: Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              splashColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Future uploadToStorage() async {
  //   try {
  //     final DateTime now = DateTime.now();
  //     final int millSeconds = now.millisecondsSinceEpoch;
  //     final String month = now.month.toString();
  //     final String date = now.day.toString();
  //     final String today = ('$month-$date');

  //     final file = await ImagePicker().pickVideo(source: ImageSource.gallery);

  //     // Reference ref = FirebaseStorage.instance
  //     //     .ref()
  //     //     .child("video")
  //     //     .child(today);
  //     // UploadTask uploadTask =
  //     //     ref.putFile(file, MetaData(contentType: 'video/mp4'));

  //     if (file != null) {
  //       //Upload to Firebase
  //       var snapshot = await FirebaseStorage.instance
  //           .ref()
  //           .child('images/imageName')
  //           .putFile(file);
  //       var downloadUrl = await snapshot.ref.getDownloadURL();
  //       setState(() {
  //         imageUrl = downloadUrl;
  //       });
  //     } else {
  //       print('No Image Path Received');
  //     }
  //   } else {
  //     print('Permission not granted. Try Again with permission access');
  //   }

  //     Uri downloadUrl = (await uploadTask.future).downloadUrl;

  //     final String url = downloadUrl.toString();

  //     print(url);
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  uploadImage() async {
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
//////https://www.youtube.com/watch?v=zIjoPL7gXfM
