import 'package:flutter/material.dart';

/// Full-screen, gallery-style photo viewer: swipe between photos, pinch or
/// double-tap to zoom, drag to pan while zoomed, tap to show/hide the bars.
///
/// [open] returns the index of the photo that was showing when the viewer was
/// closed, so the list can select it.
class PhotoGalleryViewer extends StatefulWidget {
  const PhotoGalleryViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.onLoadMore,
  });

  /// The list page's photos. It is the same list object, so photos the page
  /// loads while the viewer is open show up here too.
  final List photos;
  final int initialIndex;
  final String Function(Map photo) imageUrl;
  // Shown while the full image downloads; usually already cached by the list.
  final String Function(Map photo) thumbnailUrl;
  // Called near the end of [photos] to fetch the next set.
  final Future<void> Function()? onLoadMore;

  static Future<int?> open(
    BuildContext context, {
    required List photos,
    required int initialIndex,
    required String Function(Map photo) imageUrl,
    required String Function(Map photo) thumbnailUrl,
    Future<void> Function()? onLoadMore,
  }) {
    return Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => PhotoGalleryViewer(
          photos: photos,
          initialIndex: initialIndex,
          imageUrl: imageUrl,
          thumbnailUrl: thumbnailUrl,
          onLoadMore: onLoadMore,
        ),
      ),
    );
  }

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;
  bool _showBars = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isZoomed = false;
    });
    if (widget.onLoadMore != null && index >= widget.photos.length - 3) {
      widget.onLoadMore!().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _close() {
    Navigator.of(context).pop(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex] as Map;
    return WillPopScope(
      onWillPop: () async {
        _close();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _showBars
            ? AppBar(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _close,
                ),
                title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
              )
            : null,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              // While zoomed, drags pan the photo instead of changing page.
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              itemCount: widget.photos.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final item = widget.photos[index] as Map;
                return _ZoomablePhoto(
                  key: ValueKey(item["id"]),
                  imageUrl: widget.imageUrl(item),
                  thumbnailUrl: widget.thumbnailUrl(item),
                  onTap: () => setState(() => _showBars = !_showBars),
                  onZoomChanged: (isZoomed) {
                    if (index == _currentIndex && isZoomed != _isZoomed) {
                      setState(() => _isZoomed = isZoomed);
                    }
                  },
                );
              },
            ),
            if (_showBars)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                  child: Text(
                    "${photo["createdDate"] ?? ""}\n${photo["filePath"] ?? ""}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomablePhoto extends StatefulWidget {
  const _ZoomablePhoto({
    super.key,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.onTap,
    required this.onZoomChanged,
  });
  final String imageUrl;
  final String thumbnailUrl;
  final VoidCallback onTap;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  static const double _doubleTapScale = 2.5;
  final TransformationController _controller = TransformationController();
  late final AnimationController _animationController;
  Animation<Matrix4>? _animation;
  Offset _doubleTapPosition = Offset.zero;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() => _controller.value = _animation!.value);
    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final isZoomed = _controller.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomed != _isZoomed) {
      setState(() => _isZoomed = isZoomed);
      widget.onZoomChanged(isZoomed);
    }
  }

  // Double-tap zooms in on the tapped point, or back out if already zoomed.
  void _onDoubleTap() {
    final Matrix4 end;
    if (_isZoomed) {
      end = Matrix4.identity();
    } else {
      final position = _doubleTapPosition;
      end = Matrix4.identity()
        ..translate(-position.dx * (_doubleTapScale - 1),
            -position.dy * (_doubleTapScale - 1))
        ..scale(_doubleTapScale);
    }
    _animation = Matrix4Tween(begin: _controller.value, end: end).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 6,
        // Pan only while zoomed so a swipe at normal size changes the page.
        panEnabled: _isZoomed,
        child: SizedBox.expand(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Same cacheWidth as the list thumbnail, so it's a cache hit.
                  Image.network(
                    widget.thumbnailUrl,
                    fit: BoxFit.contain,
                    cacheWidth: (mediaQuery.size.width *
                            mediaQuery.devicePixelRatio)
                        .round(),
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  ),
                ],
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 80),
            ),
          ),
        ),
      ),
    );
  }
}
