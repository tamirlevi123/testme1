import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isScrrrenTurned =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Flex(
      direction: isScrrrenTurned ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(child: Container(color: Colors.green)),
        Expanded(child: Container(color: Colors.red)),
        Expanded(child: Container(color: Colors.blue))
      ],
    );
  }
}
