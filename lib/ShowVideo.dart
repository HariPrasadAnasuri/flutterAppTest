import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/video_status.dart';

/// Plays [videos] starting at [initialIndex]. Swipe left/right (or use the
/// buttons on the video) for the next/previous video and mark the one playing
/// with the bottom bar; nothing is marked automatically. When a video ends,
/// the next one starts after a short "Up next" countdown. [videos] is the list
/// of the video list page, so marks made here show up there too.
class ShowVideo extends StatefulWidget {
  const ShowVideo(
      {super.key,
      required this.videos,
      required this.initialIndex,
      this.onIndexChanged,
      this.onLoadMore});
  final List videos;
  final int initialIndex;
  // Called with the index of the video that is playing now
  final ValueChanged<int>? onIndexChanged;
  // Fetches the next set into [videos]; used near the end of the list so
  // playback can keep going.
  final Future<void> Function()? onLoadMore;

  @override
  State<ShowVideo> createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  static const int _upNextSeconds = 5;

  late BetterPlayerController _playerController;
  late int currentIndex;
  final TransformationController _zoomController = TransformationController();
  bool _isZoomed = false;
  // Seconds left before the next video starts; null when no countdown.
  int? _upNextSecondsLeft;
  Timer? _upNextTimer;
  // True while waiting for more videos to play the next one.
  bool _loadingMore = false;
  bool _isPaused = false;
  // Takes the TV remote / D-pad keys while the video area has focus.
  final FocusNode _remoteFocus = FocusNode(debugLabel: 'Video remote keys');

  /// TV remote / keyboard: Left/Right previous/next video, OK play/pause (or
  /// "Play now" during the Up next countdown), media keys as labelled.
  /// Up/Down are left to the focus movement, e.g. down to the mark bar.
  KeyEventResult _onRemoteKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final bool isRepeat = event is KeyRepeatEvent;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.mediaTrackNext) {
      if (!isRepeat) _playVideo(currentIndex + 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.mediaTrackPrevious) {
      if (!isRepeat) _playVideo(currentIndex - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.mediaPlayPause) {
      if (!isRepeat) {
        if (_upNextSecondsLeft != null) {
          _playVideo(currentIndex + 1);
        } else {
          _togglePlayPause();
        }
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaFastForward) {
      _seekBy(const Duration(seconds: 10));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaRewind) {
      _seekBy(const Duration(seconds: -10));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _togglePlayPause() {
    if (_playerController.isPlaying() == true) {
      _playerController.pause();
    } else {
      _playerController.play();
    }
  }

  void _seekBy(Duration offset) {
    final position = _playerController.videoPlayerController?.value.position;
    if (position == null) return;
    final target = position + offset;
    _playerController.seekTo(target < Duration.zero ? Duration.zero : target);
  }

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
    _prefetchIfNearEnd();
  }

  @override
  void dispose() {
    _upNextTimer?.cancel();
    _remoteFocus.dispose();
    // Ensure disposing of the player controller to free up resources.
    _playerController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  BetterPlayerController _createPlayerController(int index) {
    final controller = BetterPlayerController(
      const BetterPlayerConfiguration(
          allowedScreenSleep: false,
          autoPlay: true,
          // The frame is resized to the whole screen area in build(); contain
          // fits portrait and landscape videos into it without cropping.
          fit: BoxFit.contain,
          expandToFill: true,
          // Full-screen button: portrait videos stay in portrait.
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true),
      betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          AppValues.getUrlForVideo(widget.videos[index]['id'])),
    );
    // The identical() check skips events from a player that has already
    // been replaced.
    controller.addEventsListener((event) {
      if (!mounted || !identical(controller, _playerController)) return;
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        _startUpNext();
      } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        // Replaying the video cancels the countdown.
        _cancelUpNext();
        if (_isPaused) setState(() => _isPaused = false);
      } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        if (!_isPaused) setState(() => _isPaused = true);
      }
    });
    return controller;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), duration: const Duration(milliseconds: 1500)),
    );
  }

  // Load the next set in the background before the last video is reached.
  void _prefetchIfNearEnd() {
    if (widget.onLoadMore != null && currentIndex >= widget.videos.length - 3) {
      widget.onLoadMore!().then((_) {
        // Updates the count in the title and the next button
        if (mounted) setState(() {});
      });
    }
  }

  void _startUpNext() {
    _upNextTimer?.cancel();
    setState(() => _upNextSecondsLeft = _upNextSeconds);
    _upNextTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_upNextSecondsLeft! <= 1) {
        _playVideo(currentIndex + 1);
      } else {
        setState(() => _upNextSecondsLeft = _upNextSecondsLeft! - 1);
      }
    });
  }

  void _cancelUpNext() {
    _upNextTimer?.cancel();
    _upNextTimer = null;
    if (_upNextSecondsLeft != null) {
      setState(() => _upNextSecondsLeft = null);
    }
  }

  Future<void> _playVideo(int newIndex) async {
    _cancelUpNext();
    if (_loadingMore) return;
    if (newIndex < 0) {
      _showMessage("This is the first video");
      return;
    }
    if (newIndex >= widget.videos.length) {
      if (widget.onLoadMore != null) {
        final indexBeforeLoad = currentIndex;
        setState(() => _loadingMore = true);
        await widget.onLoadMore!();
        if (!mounted) return;
        setState(() => _loadingMore = false);
        // The user moved to another video while it was loading
        if (currentIndex != indexBeforeLoad) return;
      }
      if (newIndex >= widget.videos.length) {
        _showMessage("No more videos");
        return;
      }
    }
    final oldController = _playerController;
    oldController.pause();
    setState(() {
      currentIndex = newIndex;
      _playerController = _createPlayerController(newIndex);
      _isPaused = false;
    });
    // Keep the remote keys working if focus was on the mark bar
    _remoteFocus.requestFocus();
    _resetZoom();
    // The old player widget still uses its controller until this frame is
    // built, so dispose it afterwards.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => oldController.dispose());
    widget.onIndexChanged?.call(newIndex);
    _prefetchIfNearEnd();
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
    final bool hasNextLoaded = currentIndex < widget.videos.length - 1;
    return WillPopScope(
      // Back during the Up next countdown cancels it instead of leaving.
      onWillPop: () async {
        if (_upNextSecondsLeft == null) return true;
        _cancelUpNext();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
        body: Focus(
          focusNode: _remoteFocus,
          autofocus: true,
          onKeyEvent: _onRemoteKey,
          child: GestureDetector(
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
              child: LayoutBuilder(builder: (context, constraints) {
                // Make the player frame fill the whole body so portrait videos
                // use the full height instead of sitting in a 16:9 box.
                _playerController.setOverriddenAspectRatio(
                    constraints.maxWidth / constraints.maxHeight);
                return Stack(
                  children: [
                    // Pinch to zoom (up to 5x); drag to pan once zoomed.
                    InteractiveViewer(
                      transformationController: _zoomController,
                      minScale: 1,
                      maxScale: 5,
                      panEnabled: _isZoomed,
                      // The player's own controls must not take the remote's
                      // focus, or they swallow the arrow keys handled above.
                      child: ExcludeFocus(
                        child: BetterPlayer(
                          // A new player widget for every video
                          key: ValueKey(currentIndex),
                          controller: _playerController,
                        ),
                      ),
                    ),
                    if (_isPaused && _upNextSecondsLeft == null)
                      const IgnorePointer(
                        child: Center(
                          child: Icon(Icons.pause_circle_filled,
                              size: 96, color: Colors.white70),
                        ),
                      ),
                    if (currentIndex > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _SkipButton(
                          icon: Icons.skip_previous,
                          tooltip: 'Previous video',
                          onPressed: () => _playVideo(currentIndex - 1),
                        ),
                      ),
                    // With onLoadMore there may be more videos after the last
                    // loaded one, so keep the button.
                    if (hasNextLoaded || widget.onLoadMore != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _SkipButton(
                          icon: Icons.skip_next,
                          tooltip: 'Next video',
                          onPressed: () => _playVideo(currentIndex + 1),
                        ),
                      ),
                    if (_loadingMore)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    if (_upNextSecondsLeft != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        // Above the player's own control bar
                        bottom: 64,
                        child: _UpNextCard(
                          secondsLeft: _upNextSecondsLeft!,
                          totalSeconds: _upNextSeconds,
                          nextTitle: hasNextLoaded
                              ? "${widget.videos[currentIndex + 1]['fileName']}"
                              : "Next video",
                          onCancel: _cancelUpNext,
                          onPlayNow: () => _playVideo(currentIndex + 1),
                        ),
                      ),
                  ],
                );
              })),
        ),
      ),
    );
  }
}

/// Round, semi-transparent previous/next button drawn over the video.
class _SkipButton extends StatelessWidget {
  const _SkipButton(
      {required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // For touch only; the remote uses Left/Right instead.
      child: ExcludeFocus(
        child: IconButton(
          tooltip: tooltip,
          iconSize: 36,
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: Colors.black45),
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// "Up next in N" card shown when a video ends, with Cancel and Play now.
class _UpNextCard extends StatelessWidget {
  const _UpNextCard({
    required this.secondsLeft,
    required this.totalSeconds,
    required this.nextTitle,
    required this.onCancel,
    required this.onPlayNow,
  });
  final int secondsLeft;
  final int totalSeconds;
  final String nextTitle;
  final VoidCallback onCancel;
  final VoidCallback onPlayNow;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Up next in $secondsLeft",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(nextTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: secondsLeft / totalSeconds,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onCancel, child: const Text("Cancel")),
                TextButton(onPressed: onPlayNow, child: const Text("Play now")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
