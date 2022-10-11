import 'package:flutter/material.dart';

class PinchZoomImage extends StatefulWidget {
  const PinchZoomImage({super.key});

  @override
  State<PinchZoomImage> createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<PinchZoomImage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
              fit: BoxFit.cover,
              'http://[2405:201:c018:400b:41d3:b8f9:2ed5:9089]:7000/photos/3'),
        ),
      ),
    );
  }
}
