import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';

class PinchZoomImage extends StatefulWidget {
  const PinchZoomImage({super.key});
  @override
  State<PinchZoomImage> createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<PinchZoomImage>
    with SingleTickerProviderStateMixin {
  final double minScale = 1;
  final double maxScale = 6;
  double scale = 1;
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )
      ..addListener(() {
        controller.value = animation!.value;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          removeOverlay();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        return InteractiveViewer(
          constrained: false,
          scaleEnabled: true,
          panEnabled: true,
          minScale: 0.06,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          clipBehavior: Clip.none,
          child: Image.network(fit: BoxFit.cover, AppValues.getImageUrl()),
        );
      }),
    );
  }

  void resetAnimation() {
    animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.ease),
    );
    animationController.forward(from: 0);
  }

  void showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = MediaQuery.of(context).size;

    entry = OverlayEntry(builder: ((context) {
      double opacity = ((scale - 1) / (maxScale - 1)).clamp(0.2, 1);
      return Stack(
        children: <Widget>[
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: size.width,
            child: buildImage(),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: Container(color: Colors.black),
            ),
          )
        ],
      );
    }));
    final overlay = Overlay.of(context)!;
    overlay.insert(entry!);
  }

  Image buildImage() {
    return Image.network(fit: BoxFit.cover, AppValues.imagesUrl);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }
}
