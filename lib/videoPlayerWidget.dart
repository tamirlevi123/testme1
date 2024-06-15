import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testme1/main.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final AlignmentDirectional alignment;

  const VideoPlayerWidget(
      {Key? key, required this.videoUrl, required this.alignment})
      : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late File videoFile;
  late Directory appDir;
  Future<void> getCurrentDir() async {
    appDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    super.initState();
    //String filePath = '${appDir.path}/${widget.videoUrl}';
    String filePath = '/data/user/0/com.example.testme1/app_flutter/out9.mp4';
    // Initialize the controller and store the Future for later use.
    videoFile = File(filePath);
    _controller = VideoPlayerController.file(videoFile);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool videoFileExists = videoFile.existsSync();
    mylog('videoFileExists=$videoFileExists');
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          return Container(
              color: Colors.black,
              child: Stack(
                children: [
                  if (videoFileExists &&
                      snapshot.connectionState == ConnectionState.done) ...[
                    Align(
                        alignment: Alignment.center,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Expanded(child: VideoPlayer(_controller)),
                        )),
                    Align(
                        alignment: widget.alignment,
                        child: Row(children: [
                          SizedBox.fromSize(
                              size: const Size(30, 30),
                              child: FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                },
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              )),
                          Expanded(
                              child: VideoProgressIndicator(_controller,
                                  allowScrubbing: true)),
                        ]))
                  ] else ...[
                    const Center(child: CircularProgressIndicator())
                  ]
                ],
              ));
        },
      ),
    );
  }
}
