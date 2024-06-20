//ignore: file_names
import 'dart:async';
//import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:flutter_gif/flutter_gif.dart';
import 'package:testme1/videoPlayerWidget.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:video_player/video_player.dart';

class Imager extends StatefulWidget {
  final int id;
  final String userName;
  final String imageSrc;
  final Function parentOnTap;
  final Function parentOnLongPress;
  final double opacity;
  final bool borderUp;
  final AlignmentDirectional alignment;
  final bool showCoins;
  final bool playVideo;
  final AlignmentDirectional videoBarAlignment;

  const Imager(
      {super.key,
      required this.id,
      required this.userName,
      required this.imageSrc,
      required this.parentOnTap,
      required this.parentOnLongPress,
      required this.opacity,
      required this.borderUp,
      required this.alignment,
      required this.showCoins,
      required this.playVideo,
      required this.videoBarAlignment});

  @override
  State<Imager> createState() => _ImagerState();
}

class _ImagerState extends State<Imager> with TickerProviderStateMixin {
  late FlutterGifController controller;

  @override
  void initState() {
    super.initState();
    controller = FlutterGifController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    precacheImage(img1.image, context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showCoins) {
      controller.repeat(
          min: 0, max: 4, period: const Duration(milliseconds: 1000));
      Timer(const Duration(seconds: 2), () {
        //controller.stop();
      });
    }
    return Expanded(
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1000),
            opacity: widget.opacity,
            curve: Curves.easeInOut,
            child: Stack(children: [
              Container(
                constraints: const BoxConstraints.expand(),
                margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20.0),
                  image: DecorationImage(
                      image: widget.imageSrc.length > 10
                          ? Image.network(widget.imageSrc).image
                          : Image.asset('assets/clock.jpg').image,
                      fit: BoxFit.cover),
                ),
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (widget.playVideo) return;
                      developer.log("onTap");
                      widget.parentOnTap();
                    },
                    onLongPress: () {
                      if (widget.playVideo) return;
                      developer.log("onLongPress");
                      widget.parentOnLongPress();
                    },
                    child: Stack(children: [
                      Align(
                          alignment: widget.alignment,
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                widget.userName,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                ),
                              ))),
                      if (widget.playVideo)
                        (Container(
                            color: Colors.black,
                            child: VideoPlayerWidget(
                              videoUrl: 'out9.mp4',
                              alignment: widget.videoBarAlignment,
                            )))
                    ])),
              ),
              if (widget.showCoins)
                ((GifImage(
                  controller: controller,
                  image: const AssetImage("assets/images/rainingcoins.gif"),
                ))),
              if (widget.borderUp)
                Container(color: Colors.green.withOpacity(0.3)),
            ])));
  }
}
