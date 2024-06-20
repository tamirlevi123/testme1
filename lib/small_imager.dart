import 'package:flutter/material.dart';

class SmallImager extends StatefulWidget {
  late int id;
  late String title;
  late String imageSrc;
  late Color borderColor = Colors.black;

  SmallImager({
    super.key,
    required this.id,
    required this.title,
    required this.imageSrc,
    required this.borderColor,
  });

  @override
  State<SmallImager> createState() => _SmallImagerState();
}

class _SmallImagerState extends State<SmallImager> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100,
        height: 100,
        child: Stack(children: [
          Container(
            constraints: const BoxConstraints.expand(),
            margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: widget.borderColor, width: 5),
              image: DecorationImage(
                  image: widget.imageSrc.length > 10
                      ? Image.network(widget.imageSrc).image
                      : Image.asset('assets/clock.jpg').image,
                  fit: BoxFit.cover),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),
                  ))),
        ]));
  }
}
