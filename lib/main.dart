import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:testme1/imager.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:testme1/step_candidate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final Ticker _ticker = Ticker((elapsed) {});
  List<StepCandidate> _toShow = List.empty();
  String uuid = "";
  String gameId = "";
  int stepId = -1;
  int lastClicked = -1;
  bool shouldFadeOut0 = false, shouldfadeout1 = false;
  double opacity1 = 1.0, opacity0 = 1.0;

  bool isAnimated = false;

  Future<void> playLocalAsset() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/coins.mp3'));
    return;
  }

  _MyHomePageState() {
    developer.log("Constructor");
    startGame();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void startGame() async {
// Create uuid object

    uuid = const Uuid().v4().toString();
    developer.log("uuid=$uuid");

    final response = await http.post(
      Uri.parse(
          'https://tqyqkizxh5.execute-api.eu-central-1.amazonaws.com/Dev/game/start'),
    );

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
      opacity0 = opacity1 = 1.0;
      lastClicked = -1;
      _toShow = gamemy.step.candidates;
      gameId = gamemy.gameId;
      stepId = gamemy.step.stepId;
    });
  }

  void stepFunction(int idx) async {
    developer.log("Clicked $idx");

    setState(() {
      lastClicked = idx;
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

    DateTime before = DateTime.now();

    if (idx >= 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          if (idx == 0) opacity0 = 0;
          if (idx == 1) opacity1 = 0;
        });
      });
    }

    String temp =
        'https://tqyqkizxh5.execute-api.eu-central-1.amazonaws.com/Dev/game/$gameId/play';
//    String temp = 'http://3.68.66.11/api/v1/play/$gameId/$stepId';
    developer.log('At tempFunction temp=$temp');

    String brr = jsonEncode(<String, String>{
      'selection_type': idx < 0 ? 'none' : 'one',
      'is_undo': 'false',
      'selected_number': idx < 0 ? '0' : idx.toString(),
      'step_number': stepId.toString(),
    });

    final response = await http.post(
      Uri.parse(temp),
      body: brr,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // If the server did return a OK response,
      // then parse the JSON.
      developer.log("wala???");
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }

    DateTime after = DateTime.now();
    final parsedJson = jsonDecode(response.body);

    final steppy = Steppy.fromJson(parsedJson);
    developer.log(steppy.toString());

    var delay = after.difference(before);
    int millis = 0;
    if (delay.inMilliseconds < 1500) millis = 1500 - delay.inMilliseconds;
    Future.delayed(Duration(milliseconds: millis), () {
      setState(() {
        lastClicked = -1;
        _toShow = steppy.candidates;
        stepId = steppy.stepId;

        opacity0 = opacity1 = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log("main build started");
    bool isScrrrenTurned =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // ignore: unused_local_variable
    FlutterGifController controller = FlutterGifController(vsync: this);
    return Material(
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
                              opacity: opacity0,
                              userName: _toShow[0].title,
                              id: 0,
                              imageSrc: _toShow[0].imageurl,
                              borderUp: lastClicked == 0,
                              parentOnTap: () {
                                stepFunction(0);
                              })
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
                              opacity: opacity1,
                              userName: _toShow[1].title,
                              id: 1,
                              imageSrc: _toShow[1].imageurl,
                              borderUp: lastClicked == 1,
                              parentOnTap: () {
                                stepFunction(1);
                              })
                          : Container(color: Colors.pinkAccent)
                    ],
                  ),
                  SizedBox.expand(
                      child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          developer.log('New Game pressed!');
                          startGame();
                        },
                        child: const Text('New Game'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          developer.log('None pressed!');
                          stepFunction(-1);
                        },
                        child: const Text('None'),
                      ),
                    ],
                  )),
                  SizedBox.expand(
                      child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          developer.log('New Game pressed!');
                          startGame();
                        },
                        child: const Text('New Game'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          playLocalAsset();
                        },
                        child: const Text('Play Sound'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          isAnimated = !isAnimated;
                          if (isAnimated) {
                            playLocalAsset();
                            developer.log('Animate pressed!');
                            controller.repeat(
                                min: 0,
                                max: 4,
                                period: const Duration(milliseconds: 1000));
                          } else {
                            developer.log('Stop animate pressed!');
                            controller.stop();
                          }
                        },
                        child: Text(isAnimated ? 'Stop animate' : 'Animate'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          developer.log('None pressed!');
                          stepFunction(-1);
                        },
                        child: const Text('None'),
                      ),
                    ],
                  )),
/*                  
                  GifImage(
                    controller: controller,
                    image: const AssetImage("assets/images/rainingcoins.gif"),
                  )
*/
                ]))));
  }
}
