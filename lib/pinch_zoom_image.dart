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
  final double maxScale = 4;
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
          transformationController: controller,
          clipBehavior: Clip.none,
          minScale: minScale,
          maxScale: maxScale,
          onInteractionStart: (details) {
            if (details.pointerCount < 2) return;
            showOverlay(context);
          },
          onInteractionUpdate: (details) {
            if (entry == null) return;
            scale = details.scale;
            entry!.markNeedsBuild();
          },
          onInteractionEnd: ((details) {
            resetAnimation();
          }),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(fit: BoxFit.cover, AppValues.imagesUrl),
            ),
          ),
        );
      }),
    );
  }

  void resetAnimation() {
    animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
    animationController.forward(from: 0);
  }

  void showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = MediaQuery.of(context).size;

    entry = OverlayEntry(builder: ((context) {
      double opacity = ((scale - 1) / (maxScale - 1)).clamp(0, 1);
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: Container(color: Colors.black),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: size.width,
            child: buildImage(),
          ),
        ],
      );
    }));
    final overlay = Overlay.of(context)!;
    overlay.insert(entry!);
  }

  AspectRatio buildImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(fit: BoxFit.cover, AppValues.imagesUrl),
      ),
    );
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }
}
