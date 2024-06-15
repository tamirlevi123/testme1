import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:io';
import 'dart:ui';
//import 'dart:typed_data';
//import 'dart:typed_data';
//import 'dart:ui';
//import 'dart:js';
import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_gif/flutter_gif.dart';
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:testme1/imager.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:testme1/step_candidate.dart';
import 'package:image/image.dart' as pxl_img;
import 'package:path_provider/path_provider.dart';
//import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_state/screen_state.dart';

void main() {
  final context = SecurityContext.defaultContext;
  context.allowLegacyUnsafeRenegotiation = true;
  final httpClient = HttpClient(context: context);
  ioclient = IOClient(httpClient);

  runApp(const MyApp());
}

IOClient ioclient = IOClient(HttpClient());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class ScreenStateEventEntry {
  ScreenStateEvent event;
  DateTime? time;

  ScreenStateEventEntry(this.event) {
    time = DateTime.now();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

void mylog(String line) {
  String toLog = "${DateTime.now()} $line";
  developer.log(toLog);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late VideoPlayerController _controller;

  double videoPosition = 0;

  final Ticker _ticker = Ticker((elapsed) {});
  List<StepCandidate> _toShow = List.empty();
  List<StepCandidate> _toBack = List.empty();
  String uuid = "";
  String gameId = "";
  int stepId = -1;
  int lastClicked = -1;
  bool shouldFadeOut0 = false, shouldfadeout1 = false;
  bool borderUp0 = false, borderUp1 = false;
  double opacity1 = 1.0, opacity0 = 1.0;
  bool hideButtons = false;
  bool playVideo0 = false, playVideo1 = false;
  bool isBack = false;
  bool isStartScreen = true;

  bool isAnimated = false;

  Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent>? _subscription;
  bool started = false;
  List<ScreenStateEventEntry> _log = [];

  @override
  void initState() {
    super.initState();
    startListening();
  }

  /// Start listening to screen events
  void startListening() {
    try {
      _subscription = _screen.screenStateStream!.listen(_onData);
    } on ScreenStateException catch (exception) {
      mylog(exception.toString());
    }
  }

  void _onData(ScreenStateEvent event) {
    mylog(event.toString());
  }

  /// Stop listening to screen events
  void stopListening() {
    _subscription?.cancel();
  }

  TextEditingController textController = TextEditingController();

  Future<void> loadImage(listToVideo) async {
    mylog("AAA");

    final directory = await getApplicationDocumentsDirectory();
    final dirName = directory.path;
    int ctr = 1;
    mylog("listToVideo=$listToVideo");
    var sumsum = [];
    mylog('sumsum.length= , $sumsum.length');
    for (var sc in listToVideo) {
      int idTemp = sc["id"];
      mylog('idTemp=$idTemp');
      int idx2 = chosenHistory.indexWhere((ch) => ch.id == idTemp);
      if (idx2 >= 0) {
        sumsum.add(chosenHistory[idx2]);
      } else {
        mylog('couldnt find sc=$sc');
      }
    }

    mylog("sumsum=$sumsum");
    pxl_img.Image tempPrev = sumsum.first.imgBytes!;
    for (int i = 1; i < sumsum.length; i++) {
      pxl_img.Image tempNext = sumsum[i].imgBytes!;
      List<pxl_img.Image> destImages = [];

      mylog("BBB");
      int framesToCreatePerTransit = 10;

      mylog('tempPrev.size=${tempPrev.width}X${tempPrev.height}');
      mylog('tempNext.size=${tempNext.width}X${tempNext.height}');

      var destWidth = 250, destHesight = 250;
      for (int s = 0; s <= framesToCreatePerTransit; s++) {
        destImages.add(pxl_img.Image(width: destWidth, height: destHesight));
      }
      double wr1 = tempPrev.width / destWidth;
      double hr1 = tempPrev.height / destHesight;
      double wr2 = tempNext.width / destWidth;
      double hr2 = tempNext.height / destHesight;
      for (int r = 0; r < destHesight; r++) {
        for (int c = 0; c < destWidth; c++) {
          pxl_img.Pixel destPixel, srcPrev, srcNext;
          int a1 = -1, a2 = -1, b1 = -1, b2 = -1;
          try {
            a1 = (c * wr1).toInt();
            b1 = (r * hr1).toInt();
            //mylog('a1=$a1, b1=$b1');
            srcPrev = tempPrev.getPixel(a1, b1);
            a2 = (c * wr2).toInt();
            b2 = (r * hr2).toInt();
            //mylog('a2=$a2, b2=$b2');
            srcNext = tempNext.getPixel(a2, b2);

            for (int s = 0; s <= framesToCreatePerTransit; s++) {
              double t;
              if (s == 0) {
                t = 0;
              } else if (s == framesToCreatePerTransit) {
                t = 1.0;
              } else {
                t = 1 / framesToCreatePerTransit * s;
              }

              destPixel = destImages[s].getPixel(c, r);

              num dr = srcPrev.r * (1 - t) + srcNext.r * t;
              num dg = srcPrev.g * (1 - t) + srcNext.g * t;
              num db = srcPrev.b * (1 - t) + srcNext.b * t;

              destPixel.setRgb(dr, dg, db);
            }
          } catch (e) {
            mylog('a1=$a1, b1=$b1, a2=$a2, b2=$b2');
            mylog(e.toString());
          }
        }
      }
      // Encode the resulting image to the PNG image format.
      for (int s = 0; s < destImages.length; s++) {
        final png = pxl_img.encodeJpg(destImages[s]);
        File bla = File('$dirName/dest${ctr.toString()}.jpg');
        bla.writeAsBytes(png);
        ctr++;
      }

      tempPrev = tempNext;
    }
    String outputFile = '$dirName/out9.mp4';
    File outFile = File(outputFile);
    if (outFile.existsSync()) outFile.deleteSync();

    String cmd = '-framerate 10 -i $dirName/dest%d.jpg $outputFile';
    FFmpegKit.execute(cmd).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        mylog("sababa");
        // Create and store the VideoPlayerController. The VideoPlayerController
        // offers several different constructors to play videos from assets, files,
        // or the internet.

        _controller = VideoPlayerController.file(File(outputFile));
      } else if (ReturnCode.isCancel(returnCode)) {
        mylog("cancel");
      } else {
        mylog("error");
      }
    });

    mylog("After");
  }

  Future<void> deletePngFiles() async {
    try {
      // Get the directory
      final directory = await getApplicationDocumentsDirectory();
      // List all files in the directory
      final files = directory.listSync();

      for (var file in files) {
        //String str = basename(file.path);
        if (file.path.endsWith('.jpg') || file.path.endsWith('.mp4')) {
          await file.delete();
          mylog('Deleted: ${file.path}');
        }
      }
    } catch (e) {
      mylog('Error deleting files: $e');
    }
  }

  Future<void> playLocalAsset() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/coins.mp3'));
    return;
  }

  _MyHomePageState() {
    developer.log("Constructor");
    // startGame();
  }

  @override
  void dispose() {
    textController.dispose();
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void startGame() async {
    startListening();
    isStartScreen = false;
    Map<String, Object> tempMap = {
      'client_type': 'MOBILE_APP',
    };
    chosenHistory = [];
    deletePngFiles();

    String sp = textController.text.trim();
    developer.log("Start game, startingId=$sp");
    if (sp.isNotEmpty) {
      int? spInt = int.tryParse(sp);
      if (spInt == null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Starting point"),
                content: Text("Your starting point $sp is inparsable"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              );
            });
        return;
      } else {
        tempMap['first_candidate_id'] = sp;
      }
    }

    String brr = jsonEncode(tempMap);

    final response = await http.post(
        Uri.parse('https://api.bongo-ai.com/game/start'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: brr);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // If the server did return a OK response,
      // then parse the JSON.
      developer.log("wala???");
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      developer.log("failed to get new game response");
    }

    final parsedJson = jsonDecode(response.body);
// type: Restaurant
    final gamemy = Game.fromJson(parsedJson);
    developer.log(gamemy.toString());

    setState(() {
      borderUp0 = borderUp1 = false;
      hideButtons = false;
      opacity0 = opacity1 = 1.0;
      lastClicked = -1;
      _toShow = gamemy.step.candidates;
      gameId = gamemy.gameId;
      stepId = gamemy.step.stepId;
      playVideo0 = playVideo1 = false;
      videoPosition = 0;
    });

    for (StepCandidate sc in gamemy.step.candidates) {
      final file = await DefaultCacheManager().getSingleFile(sc.imageurl);
      sc.imgBytes = pxl_img.decodeImage(await file.readAsBytes());
      chosenHistory.add(sc);
    }
  }

  void bingoFunction(int idx) async {
    developer.log("bingoFunction idx= $idx");

    for (int i = 0; i < chosenHistory.length; i++) {
      developer.log("chosenHistory[$i]");
      developer.log(chosenHistory[i].toString());
    }
    setState(() {
      hideButtons = true;
      lastClicked = idx;
      //opacity0 = opacity1 = 0.0;

      switch (idx) {
        case -1:
          opacity0 = opacity1 = 0.0;
          break;
        case 0:
          opacity0 = 1.0;
          opacity1 = 0.0;
          break;
        case 1:
          opacity0 = 0.0;
          opacity1 = 1.0;
          break;
      }
    });

    String temp = 'https://api.bongo-ai.com/game/$gameId/finish';
    developer.log('At tempFunction temp=$temp');

    var candidet = _toShow[idx];

    Map<String, Object> tempMap = {
      'bongo_candidate_id': candidet.id
      //,'bongo_object_name': candidet.title,
    };

    String brr = jsonEncode(tempMap);

    final response = await http.post(Uri.parse(temp),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: brr);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // If the server did return a OK response,
      // then parse the JSON.
      developer.log("wala???");
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }

    final parsedJson = jsonDecode(response.body);
    mylog(parsedJson.toString());
    var listToVideo = parsedJson['images_path'];
/*
    setState(() {
      borderUp0 = borderUp1 = false;
      playVideo0 = idx == 0;
      playVideo1 = idx == 0;
      opacity0 = opacity1 = 1.0;
    });
*/
    await loadImage(listToVideo);
    mylog('finished loadImage(idx=$idx)');

    var timetowait = 1500 + 200 * listToVideo.length;
    mylog('timetowait=$timetowait');
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        borderUp0 = borderUp1 = false;
        playVideo0 = idx == 1;
        playVideo1 = idx == 0;
        opacity0 = opacity1 = 1.0;
      });
    });
  }

  List<StepCandidate> chosenHistory = [];

  void stepFunction(int idx) async {
    developer.log("Clicked $idx");
    final brightness = PlatformDispatcher.instance.platformBrightness;
    mylog("brightness=$brightness");
    if (brightness == Brightness.dark) {
      mylog("Ignoring first click on dark");
      return;
    }
    setState(() {
      borderUp0 = idx == 0;
      borderUp1 = idx == 1;
      switch (idx) {
        case -1:
          opacity0 = opacity1 = 0.0;
          break;
        case 0:
          opacity0 = 1.0;
          opacity1 = 0.0;
          break;
        case 1:
          opacity0 = 0.0;
          opacity1 = 1.0;
          break;
      }
    });

    if (isBack) {
      isBack = false;
      if (lastClicked == idx) {
        // rechose the same picture
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            borderUp0 = borderUp1 = false;
            _toShow = [
              chosenHistory[chosenHistory.length - 2],
              chosenHistory[chosenHistory.length - 1]
            ];

            opacity0 = opacity1 = 1.0;
          });
        });
        return;
      } else {
        stepId--;
      }
    } else {
      _toBack = _toShow;
    }

    lastClicked = idx;

    DateTime before = DateTime.now();

    if (idx >= 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          if (idx == 0) opacity0 = 0;
          if (idx == 1) opacity1 = 0;
        });
      });
    }

    String selectionType = 'none';
    if (idx == 0) selectionType = 'first';
    if (idx == 1) selectionType = 'second';

    Map<String, Object> tempMap = {
      'selection_type': selectionType,
      'is_bingo': false,
    };

    String brr = jsonEncode(tempMap);

    final response = await http.post(
        Uri.parse('https://api.bongo-ai.com/game/$gameId/play/$stepId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: brr);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // If the server did return a OK response,
      // then parse the JSON.
      mylog("wala???");
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      mylog('Failed to create album.');
    }

    DateTime after = DateTime.now();
    final parsedJson = jsonDecode(response.body);

    final steppy = Steppy.fromJson(parsedJson);
    developer.log(steppy.toString());

    var delay = after.difference(before);
    int millis = 0;
    if (delay.inMilliseconds < 600) millis = 600 - delay.inMilliseconds;

    for (StepCandidate sc in steppy.candidates) {
      final file = await DefaultCacheManager().getSingleFile(sc.imageurl);
      sc.imgBytes = pxl_img.decodeImage(await file.readAsBytes());
      chosenHistory.add(sc);
    }

    Future.delayed(Duration(milliseconds: millis), () {
      setState(() {
        borderUp0 = borderUp1 = false;
        _toShow = steppy.candidates;
        stepId = steppy.stepId;

        opacity0 = opacity1 = 1.0;
      });
    });
  }

  void backFunction() async {
    developer.log("starting backFunction");
    isBack = true;

    setState(() {
      //lastClicked = -1;
      _toShow = _toBack;
      opacity0 = opacity1 = 1.0;
    });
  }

  showBongoDialog(idx) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('R U Sure ?'),
            content: const Text(
                'Click \'Bongo\' to confirm ,or \'Cancel\' to go Back'),
            actions: [
              TextButton(
                onPressed: () {
                  mylog('OK $idx');
                  Navigator.pop(context);
                  bingoFunction(idx);
                },
                child: const Text('Bongo'),
              ),
              TextButton(
                onPressed: () {
                  mylog('Cancel $idx');
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  bool isSababa = true;
  @override
  Widget build(BuildContext context) {
    developer.log("main build started");
    bool isScrrrenTurned =
        MediaQuery.of(context).orientation == Orientation.landscape;

    mylog('playVideo0=$playVideo0, playVideo1 = $playVideo1');
    return isStartScreen
        ? Scaffold(
            appBar: AppBar(
              title: const Text("Bongo.com"),
              centerTitle: true,
              actions: [
                PopupMenuButton(onSelected: (value) {
                  // your logic
                  mylog("onSelected value=$value");
                  if (value == "sababa") isSababa = !isSababa;
                  //Navigator.pushNamed(context, value.toString());
                }, itemBuilder: (BuildContext bc) {
                  return [
                    const PopupMenuItem(
                      value: '/hello',
                      child: Text("Hello"),
                    ),
                    CheckedPopupMenuItem(
                      checked: isSababa,
                      value: 'sababa',
                      child: const Text("Sababa"),
                    ),
                    const PopupMenuItem(
                      value: '/contact',
                      child: Text("Contact"),
                    )
                  ];
                })
              ],
            ),
            body: SizedBox.expand(
              child: Material(
                  child: SafeArea(
                      child: Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 110,
                        width: 300,
                        child: (IconButton(
                            highlightColor: Colors.orange.withOpacity(0.3),
                            icon: Image.asset(
                                "assets/images/Play-Now-Button.png"),
                            onPressed: () {
                              developer.log("You tapped the Play Now button.");
                              startGame();
                            }))),
                    SizedBox(
                      width: 150.0,
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Start point....',
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
            ),
          )
        : Material(
            child: SafeArea(
                child: Container(
                    color: Colors.black,
                    child: Stack(children: [
                      Flex(
                        direction:
                            isScrrrenTurned ? Axis.horizontal : Axis.vertical,
                        children: [
                          _toShow.length > 1
                              ? Imager(
                                  videoBarAlignment: !isScrrrenTurned
                                      ? AlignmentDirectional.topCenter
                                      : AlignmentDirectional.bottomCenter,
                                  playVideo: playVideo0,
                                  showCoins: hideButtons && lastClicked == 0,
                                  alignment: isScrrrenTurned
                                      ? AlignmentDirectional.bottomStart
                                      : AlignmentDirectional.topStart,
                                  opacity: opacity0,
                                  userName: _toShow[0].title,
                                  id: 0,
                                  imageSrc: _toShow[0].imageurl,
                                  borderUp: borderUp0,
                                  parentOnTap: () {
                                    stepFunction(0);
                                  },
                                  parentOnLongPress: () {
                                    mylog('Long Press 0');
                                    if (playVideo0 || playVideo1) return;
                                    showBongoDialog(0);
                                  },
                                )
                              : Container(color: Colors.amber),
                          (isScrrrenTurned)
                              ? const VerticalDivider(
                                  color: Colors.white,
                                  thickness: 3.0,
                                )
                              : const Divider(
                                  color: Colors.white,
                                  thickness: 3.0,
                                ),
                          _toShow.length > 1
                              ? Imager(
                                  videoBarAlignment:
                                      AlignmentDirectional.bottomCenter,
                                  playVideo: playVideo1,
                                  showCoins: hideButtons && lastClicked == 1,
                                  alignment: isScrrrenTurned
                                      ? AlignmentDirectional.bottomEnd
                                      : AlignmentDirectional.bottomStart,
                                  opacity: opacity1,
                                  userName: _toShow[1].title,
                                  id: 1,
                                  imageSrc: _toShow[1].imageurl,
                                  borderUp: borderUp1,
                                  parentOnTap: () {
                                    stepFunction(1);
                                  },
                                  parentOnLongPress: () {
                                    mylog('Long Press 1');
                                    if (playVideo0 || playVideo1) return;
                                    showBongoDialog(1);
                                  },
                                )
                              : Container(color: Colors.pinkAccent)
                        ],
                      ),
                      SizedBox.expand(
                          child: Flex(
                        direction:
                            isScrrrenTurned ? Axis.vertical : Axis.horizontal,
                        children: [
                          /*


                          ElevatedButton(
                            onPressed: () {
                              developer.log('New Game pressed!');
                              startGame();
                            },
                            child: const SizedBox(
                                width: 50.0, child: Text('New Game')),
                          ),
                          SizedBox(
                            width: 100.0,
                            child: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Start point....',
                              ),
                            ),
                          ),
                          const Spacer(),
                          */
                          if (!hideButtons && stepId > 1 && !isBack) ...[
                            (Stack(children: [
                              Flex(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  direction: isScrrrenTurned
                                      ? Axis.horizontal
                                      : Axis.vertical,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Image.network(_toBack[0].imageurl),
                                    ),
                                    SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: IconButton(
                                          highlightColor:
                                              Colors.orange.withOpacity(0.5),
                                          icon: Image.network(
                                              _toBack[1].imageurl),
                                          onPressed: () {
                                            mylog(
                                                "You tapped the go back first image.");
                                          },
                                        ))
                                  ]),
                              Flex(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  direction: isScrrrenTurned
                                      ? Axis.horizontal
                                      : Axis.vertical,
                                  children: [
                                    IconButton(
                                        highlightColor:
                                            Colors.orange.withOpacity(0.5),
                                        icon: Image.asset(
                                            "assets/images/yellow_arrow.png"),
                                        iconSize: 34,
                                        onPressed: () {
                                          developer.log(
                                              "You tapped the go back icon.");
                                          backFunction();
                                        })
                                  ])
                            ]))
                          ],
                          if (!hideButtons && stepId > 5) ...[
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero, // Set this
                                padding: const EdgeInsetsDirectional.all(
                                    2.0), // and this
                              ),
                              onPressed: () {
                                developer.log('End game pressed!');
                                showEndGameDialog(0);
                              },
                              child: const Text('End Game'),
                            )
                          ],
                          if (!hideButtons && stepId > 0) ...[
                            const Spacer(),
                            (IconButton(
                              highlightColor: Colors.orange.withOpacity(0.3),
                              icon: Image.asset("assets/images/scales.png"),
                              iconSize: 70,
                              onPressed: () {
                                developer.log("You tapped the scales image.");
                                stepFunction(-1);
                              },
                            ))
                          ],
                        ],
                      )),
                      if (!hideButtons)
                        (SizedBox.expand(
                            child: Flex(
                                crossAxisAlignment: isScrrrenTurned
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                direction: isScrrrenTurned
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero, // Set this
                                  padding: const EdgeInsetsDirectional.all(
                                      2.0), // and this
                                ),
                                onPressed: () {
                                  developer.log('Bongo 0 pressed!');
                                  showBongoDialog(0);
                                },
                                child: const Text('Bongo'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero, // Set this
                                  padding: const EdgeInsetsDirectional.all(
                                      2.0), // and this
                                ),
                                onPressed: () {
                                  developer.log('Bongo 1 pressed!');
                                  showBongoDialog(1);
                                },
                                child: const Text('Bongo'),
                              )
                            ]))),
/*                        
                  if (playVideo1 || playVideo0) ...[
                    Align(
                        alignment: videoAllignment,
                        child: const Expanded(
                            child: VideoPlayerWidget(videoUrl: 'out9.mp4')))
                  ]
                  */
                    ]))));
  }

  void tempOnChanged(bool? value) {
    mylog("tempOnChanged value=$value");
  }

  void showEndGameDialog(int i) {
    mylog("showEndGameDialog i=$i");
    bool isScrrrenTurned =
        MediaQuery.of(context).orientation == Orientation.landscape;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('You want to end the game ?'),
            content: Text(isScrrrenTurned
                ? 'Click \'Left\' to confirm left exit, \'Cancel\' to go Back and \'Right\' to confirm right exit'
                : 'Click \'Top\' to confirm top exit, \'Cancel\' to go Back and \'Bottom\' to confirm bottom exit'),
            actions: [
              TextButton(
                onPressed: () {
                  //mylog('OK $idx');
                  Navigator.pop(context);
                  bingoFunction(0);
                },
                child: Text(isScrrrenTurned ? 'Left' : 'Top'),
              ),
              TextButton(
                onPressed: () {
                  mylog('Cancel clicked');
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  //mylog('OK $idx');
                  Navigator.pop(context);
                  bingoFunction(1);
                },
                child: Text(isScrrrenTurned ? 'Right' : 'Bottom'),
              ),
            ],
          );
        });
  }
}
