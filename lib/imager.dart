// ignore: file_names
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class Imager extends StatefulWidget {
  final int id;
  final String userName;
  final String imageSrc;
  final Function parentOnTap;
  final double opacity;
  final bool borderUp;

  const Imager(
      {super.key,
      required this.id,
      required this.userName,
      required this.imageSrc,
      required this.parentOnTap,
      required this.opacity,
      required this.borderUp});

  @override
  State<Imager> createState() => _ImagerState();
}

class _ImagerState extends State<Imager> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    precacheImage(img1.image, context);
  }

  @override
  Widget build(BuildContext context) {
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
                      developer.log("onTap");
                      widget.parentOnTap();
                    },
                    child: Align(
                        alignment: AlignmentDirectional.bottomStart,
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
                            )))),
              ),
              if (widget.borderUp)
                Container(color: Colors.green.withOpacity(0.3))
            ])));
  }
}
