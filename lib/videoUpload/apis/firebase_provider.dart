import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/video_info.dart';

class FirebaseProvider {
  static saveVideo(VideoInfo video) async {
    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video.videoName)
        .set({
      'thumbUrl': video.thumbUrl,
      'coverUrl': video.coverUrl,
      'aspectRatio': video.aspectRatio,
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    });
  }

  static saveDownloadUrl(String videoName, String downloadUrl) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'videoUrl': downloadUrl,
      'finishedProcessing': true,
    }, SetOptions(merge: true));
  }

  static createNewVideo(String videoName, String rawVideoPath) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'finishedProcessing': false,
      'videoName': videoName,
      'rawVideoPath': rawVideoPath,
    });
  }

  static deleteVideo(String videoName) async {
    await FirebaseFirestore.instance
        .collection('videos')
        .doc(videoName)
        .delete();
  }

  static listenToVideos(callback) async {
    FirebaseFirestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideoInfo(qs);
      callback(videos);
    });
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      List<VideoInfo> videoInfo;
      videoInfo.add(ds.data());
      return videoInfo;
    }).toList();
  }
}
