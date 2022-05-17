import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:path/path.dart' as p;

import 'apis/encoding_provider.dart';
import 'apis/firebase_provider.dart';
import 'model/video_info.dart';
import 'widgets/player.dart';

//FlutterUploader _uploader = FlutterUploader();

class VideoBackgroundHandler extends StatelessWidget {
  const VideoBackgroundHandler({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  final String title = "Upload Video";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final thumbWidth = 300;
  List<VideoInfo> _videos = <VideoInfo>[];
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  _initialize() async {
    setState(() {
      _loading = false;
    });
    FirebaseProvider.listenToVideos((List<VideoInfo> newVideos) {
      setState(() {
        _videos = newVideos;
      });
      for (VideoInfo video in newVideos) {
        if (video.uploadComplete) {
          _saveDownloadUrl(video);
        } else if (video.uploadUrl != null) {
          _processVideo(video);
        }
      }
    });

    EncodingProvider.enableStatisticsCallback((Statistics stats) {
      if (_canceled) return;

      setState(() {
        _progress = stats.time / _videoDuration;
      });
    });
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final Reference ref =
        FirebaseStorage.instance.ref().child(folderName).child(basename);

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.snapshot;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  Future<void> _saveDownloadUrl(VideoInfo video) async {
    final Reference ref =
        FirebaseStorage.instance.ref().child('${video.videoName}.mp4');

    String url = await ref.getDownloadURL();
    await FirebaseProvider.saveDownloadUrl(video.videoName, url);
  }

  Future<void> _processVideo(VideoInfo video) async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/${video.videoName}';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = video.rawVideoPath;
    if (!File(rawVideoPath).existsSync()) return;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio = EncodingProvider.getAspectRatio(info);

    setState(() {
      _processPhase = 'Generating thumbnail';
      _videoDuration = EncodingProvider.getDuration(info);
      _progress = 0.0;
    });

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, thumbWidth);

    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');

    setState(() {
      _processPhase = 'Saving video metadata to cloud firestore';
      _progress = 0.0;
    });

    final videoInfo = VideoInfo(
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: video.videoName,
    );
    await FirebaseProvider.saveVideo(videoInfo);

    setState(() {
      _processPhase = 'Starting background upload task';
      _progress = 0.0;
    });

    setState(() {
      _processPhase = 'Waiting for processing completed status from cloud';
      _progress = 0.0;
    });
  }

  void _takeVideo() async {
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    _imagePickerActive = false;

    if (result == null) return;

    setState(() {
      _processing = true;
    });

    try {
      final String rand = '${new Random().nextInt(10000)}';
      final videoName = 'video$rand';
      await FirebaseProvider.createNewVideo(
          videoName, result.files.single.path);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _videos.length,
        itemBuilder: (BuildContext context, int index) {
          final video = _videos[index];

          return GestureDetector(
            onTap: () {
              if (!video.finishedProcessing) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Player(
                      video: video,
                    );
                  },
                ),
              );
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (video.thumbUrl != null)
                      Stack(
                        children: <Widget>[
                          Container(
                            width: thumbWidth.toDouble(),
                            height: video.aspectRatio * thumbWidth.toDouble(),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: video.thumbUrl,
                            ),
                          ),
                        ],
                      ),
                    if (!video.finishedProcessing)
                      Container(
                        margin: new EdgeInsets.only(top: 12.0),
                        child: Text('Processing...'),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            FirebaseProvider.deleteVideo(video.videoName);
                          },
                        ),
                        Text("${video.videoName}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Center(child: _processing ? _getProgressBar() : _getListView()),
      floatingActionButton: FloatingActionButton(
          child: _processing
              ? CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Icon(Icons.add),
          onPressed: _takeVideo),
    );
  }
}
