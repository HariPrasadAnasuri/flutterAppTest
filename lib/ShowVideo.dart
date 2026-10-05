import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/video_status.dart';

/// Plays [videos] starting at [initialIndex]. Swipe left/right for the
/// next/previous video and mark the one playing with the bottom bar; nothing
/// is marked automatically. [videos] is the list of the video list page, so
/// marks made here show up there too.
class ShowVideo extends StatefulWidget {
  const ShowVideo(
      {super.key,
      required this.videos,
      required this.initialIndex,
      this.onIndexChanged});
  final List videos;
  final int initialIndex;
  // Called with the index of the video that is playing now
  final ValueChanged<int>? onIndexChanged;

  @override
  State<ShowVideo> createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  late BetterPlayerController _playerController;
  late int currentIndex;
  final TransformationController _zoomController = TransformationController();
  bool _isZoomed = false;

  void _onZoomChanged() {
    final isZoomed = _zoomController.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomed != _isZoomed) {
      setState(() => _isZoomed = isZoomed);
    }
  }

  void _resetZoom() {
    _zoomController.value = Matrix4.identity();
  }

  @override
  void initState() {
    super.initState();
    _zoomController.addListener(_onZoomChanged);
    currentIndex = widget.initialIndex;
    _playerController = _createPlayerController(currentIndex);
  }

  @override
  void dispose() {
    // Ensure disposing of the player controller to free up resources.
    _playerController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  BetterPlayerController _createPlayerController(int index) {
    return BetterPlayerController(
      const BetterPlayerConfiguration(
          allowedScreenSleep: false,
          autoPlay: true,
          aspectRatio: 16 / 9,
          fit: BoxFit.fitHeight,
          expandToFill: true),
      betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          AppValues.getUrlForVideo(widget.videos[index]['id'])),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), duration: const Duration(milliseconds: 1500)),
    );
  }

  void _playVideo(int newIndex) {
    if (newIndex < 0) {
      _showMessage("This is the first video");
      return;
    }
    if (newIndex >= widget.videos.length) {
      _showMessage("Last loaded video, go back to the list to load more");
      return;
    }
    final oldController = _playerController;
    oldController.pause();
    setState(() {
      currentIndex = newIndex;
      _playerController = _createPlayerController(newIndex);
    });
    _resetZoom();
    // The old player widget still uses its controller until this frame is
    // built, so dispose it afterwards.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => oldController.dispose());
    widget.onIndexChanged?.call(newIndex);
  }

  Future<void> _mark(String action) async {
    try {
      await VideoStatus.mark(widget.videos[currentIndex], action);
    } catch (e) {
      debugPrint("Failed to mark video: $e");
      if (mounted) _showMessage("Couldn't save, please try again");
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map video = widget.videos[currentIndex];
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(
          "${currentIndex + 1}/${widget.videos.length}  ${VideoStatus.dateText(video)}",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: VideoStatusIcon(video: video, size: 36),
          ),
        ],
      ),
      floatingActionButton: _isZoomed
          ? FloatingActionButton.small(
              onPressed: _resetZoom,
              tooltip: 'Reset zoom',
              child: const Icon(Icons.zoom_out_map),
            )
          : null,
      bottomNavigationBar: VideoMarkBar(video: video, onMark: _mark),
      body: GestureDetector(
          // While zoomed, one-finger drags pan the video instead of
          // switching to the next/previous one.
          onHorizontalDragEnd: _isZoomed
              ? null
              : (DragEndDetails details) {
                  if (details.primaryVelocity! < 0) {
                    // Swiped left, play next video
                    _playVideo(currentIndex + 1);
                  } else if (details.primaryVelocity! > 0) {
                    // Swiped right, play previous video
                    _playVideo(currentIndex - 1);
                  }
                },
          child: Align(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              // Pinch to zoom (up to 5x); drag to pan once zoomed.
              child: InteractiveViewer(
                transformationController: _zoomController,
                minScale: 1,
                maxScale: 5,
                panEnabled: _isZoomed,
                child: BetterPlayer(
                  // A new player widget for every video
                  key: ValueKey(currentIndex),
                  controller: _playerController,
                ),
              ),
            ),
          )),
    );
  }
}
