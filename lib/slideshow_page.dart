import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/paged_photo_list.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

/// Full screen slideshow of the photos from [startDate] on that match
/// [filter] ('all', 'important', 'visited' or 'deleted'). It plays
/// automatically; swipe to go back/forward, tap to show/hide the controls.
/// Shows the full photos and keeps the screen on while it is open.
class SlideshowPage extends StatefulWidget {
  const SlideshowPage(
      {super.key, required this.startDate, required this.filter});
  final String startDate;
  final String filter;

  @override
  State<SlideshowPage> createState() => _SlideshowPageState();
}

class _SlideshowPageState extends State<SlideshowPage> with PagedPhotos {
  static const List<int> intervals = [3, 5, 10];
  static const Map<String, String> titles = {
    'all': 'All photos',
    'important': 'Important photos',
    'visited': 'Visited photos',
    'deleted': 'Deleted photos',
  };

  final PageController pageController = PageController();
  Timer? timer;
  int currentIndex = 0;
  int intervalSeconds = 5;
  bool playing = true;
  bool showControls = true;
  // Hides the controls again while playing, see showControlsForAWhile
  Timer? hideControlsTimer;
  static const Duration hideControlsAfter = Duration(seconds: 4);
  // Has the TV remote keys while the controls are hidden
  final FocusNode pageFocus = FocusNode(debugLabel: 'Slideshow');
  final FocusNode playButtonFocus = FocusNode(debugLabel: 'Slideshow play');
  // Photos whose full image is downloaded, the slideshow waits for these
  final Set<int> readyPhotoIds = {};
  // Saves photos to the gallery, see MainActivity.kt
  static const MethodChannel galleryChannel =
      MethodChannel('my_family/gallery');
  bool saving = false;

  // Only the paging of the mixin is used here, the ListView parts aren't.
  @override
  Uri nextSetUrl(Map? lastItem) {
    // The server returns the photos after the given date, so continue from
    // the last one already loaded.
    final String fromDate =
        lastItem == null ? widget.startDate : lastItem['createdDate'];
    return Uri.parse(AppValues.getSlideshowPhotosUrl(fromDate, widget.filter));
  }

  @override
  void initState() {
    super.initState();
    // Don't let the screen turn off during the slideshow
    Wakelock.enable();
    loadFirstSet();
  }

  @override
  void dispose() {
    Wakelock.disable();
    timer?.cancel();
    hideControlsTimer?.cancel();
    pageController.dispose();
    pageFocus.dispose();
    playButtonFocus.dispose();
    super.dispose();
  }

  Future<void> loadFirstSet() async {
    await reloadImages();
    if (!mounted) return;
    precacheNext(0);
    startTimer();
    // The controls show briefly at the start, then only the photos
    if (playing && listOfImagesInfo.isNotEmpty) showControlsForAWhile();
  }

  /// Shows the controls; while playing they hide again after
  /// [hideControlsAfter] without use. When paused they stay.
  void showControlsForAWhile({bool focusPlayButton = false}) {
    hideControlsTimer?.cancel();
    if (!showControls) setState(() => showControls = true);
    if (focusPlayButton) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) playButtonFocus.requestFocus();
      });
    }
    if (playing) hideControlsTimer = Timer(hideControlsAfter, hideControls);
  }

  void hideControls() {
    hideControlsTimer?.cancel();
    if (!mounted) return;
    setState(() => showControls = false);
    // The focused button is gone, keep the remote keys on the page
    pageFocus.requestFocus();
  }

  /// TV remote / keyboard. With the controls hidden: Left/Right change the
  /// photo and OK/Up/Down bring the controls back (Back still leaves). With
  /// them showing, keys move between the buttons as usual and keep the
  /// controls up.
  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.mediaPlayPause) {
      if (event is KeyDownEvent) setPlaying(!playing);
      return KeyEventResult.handled;
    }
    if (showControls) {
      showControlsForAWhile();
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      if (event is KeyDownEvent) showPreviousPhoto();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      if (event is KeyDownEvent) showNextPhoto(waitForDownload: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      if (event is KeyDownEvent) showControlsForAWhile(focusPlayButton: true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String shrunkImageUrl(Map photo) {
    return AppValues.getImageShrunkUrlUsingIndex(photo['id'].toString());
  }

  /// The full photo, decoded at screen size: there is no zoom here, and a
  /// full size decode of a 12 MP photo takes ~48 MB of memory. Used both to
  /// show and to precache, so the precached image is the one shown.
  ImageProvider fullImage(Map photo) {
    final mediaQuery = MediaQuery.of(context);
    return ResizeImage(
      NetworkImage(AppValues.getImageUrlUsingId(photo['id'])),
      width: (mediaQuery.size.width * mediaQuery.devicePixelRatio).round(),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), duration: const Duration(milliseconds: 1500)),
    );
  }

  /// (Re)starts the automatic switching, so the full interval starts now.
  void startTimer() {
    timer?.cancel();
    if (!mounted || !playing || listOfImagesInfo.isEmpty) return;
    timer = Timer.periodic(
        Duration(seconds: intervalSeconds), (_) => showNextPhoto());
  }

  void setPlaying(bool play) {
    setState(() => playing = play);
    if (play) {
      // Pressing play after loading the next set failed tries it again
      if (loadFailed) retryLoad();
      startTimer();
    } else {
      timer?.cancel();
    }
    // Paused: the controls stay. Playing: they hide again after a while.
    showControlsForAWhile();
  }

  /// [waitForDownload]: the timer waits until the next full photo is
  /// downloaded (the next tick tries again), the Next button doesn't.
  Future<void> showNextPhoto({bool waitForDownload = true}) async {
    if (currentIndex + 1 < listOfImagesInfo.length) {
      if (waitForDownload &&
          !readyPhotoIds.contains(listOfImagesInfo[currentIndex + 1]['id'])) {
        precacheNext(currentIndex);
        return;
      }
      pageController.nextPage(
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      return;
    }
    // At the last loaded photo, load the next set first
    if (hasMore && !loadFailed) {
      await loadMore();
      if (!mounted) return;
      if (currentIndex + 1 < listOfImagesInfo.length) {
        if (waitForDownload) {
          // Shown on the next tick, once its full photo is downloaded
          precacheNext(currentIndex);
        } else {
          pageController.nextPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut);
        }
        return;
      }
    }
    if (isLoading) return; // Still loading, try again on the next tick
    if (loadFailed) {
      setPlaying(false);
      showMessage("Couldn't load more photos, press play to try again");
    } else if (!hasMore) {
      setPlaying(false);
      showMessage("That was the last photo");
    }
  }

  void showPreviousPhoto() {
    if (currentIndex == 0) {
      showMessage("This is the first photo");
      return;
    }
    pageController.previousPage(
        duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  void onPageChanged(int index) {
    setState(() => currentIndex = index);
    // Load the next set well before the end, so the slideshow doesn't wait
    if (index >= listOfImagesInfo.length - 10) loadMore();
    precacheNext(index);
    // Swiping by hand gives the photo the full interval too
    startTimer();
  }

  /// Downloads the next two full photos already, so they show without
  /// waiting.
  void precacheNext(int index) {
    for (int i = index + 1;
        i <= index + 2 && i < listOfImagesInfo.length;
        i++) {
      final Map photo = listOfImagesInfo[i];
      // Also completes when the download fails, so a broken photo doesn't
      // stop the slideshow.
      precacheImage(fullImage(photo), context)
          .then((_) => readyPhotoIds.add(photo['id']));
    }
  }

  /// Saves the full photo shown now to Pictures/My Family on the device.
  Future<void> saveCurrentPhoto() async {
    if (saving || listOfImagesInfo.isEmpty) return;
    final Map photo = listOfImagesInfo[currentIndex];
    setState(() => saving = true);
    try {
      final response =
          await http.get(Uri.parse(AppValues.getImageUrlUsingId(photo['id'])));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      String mimeType = response.headers['content-type'] ?? 'image/jpeg';
      if (!mimeType.startsWith('image/')) mimeType = 'image/jpeg';
      String extension = mimeType.substring('image/'.length).split(';').first;
      if (extension == 'jpeg') extension = 'jpg';
      final arguments = {
        'bytes': response.bodyBytes,
        'name': 'photo_${photo['id']}.$extension',
        'mimeType': mimeType,
      };
      try {
        await galleryChannel.invokeMethod('saveImage', arguments);
      } on PlatformException catch (e) {
        // Android 9 and older need the storage permission first
        if (e.code != 'PERMISSION' ||
            !(await Permission.storage.request()).isGranted) rethrow;
        await galleryChannel.invokeMethod('saveImage', arguments);
      }
      if (mounted) showMessage('Saved to Pictures/My Family');
    } catch (e) {
      debugPrint('Saving photo ${photo['id']} failed: $e');
      if (mounted) showMessage("Couldn't save the photo");
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void changeInterval() {
    final int next =
        (intervals.indexOf(intervalSeconds) + 1) % intervals.length;
    setState(() => intervalSeconds = intervals[next]);
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: pageFocus,
        autofocus: true,
        onKeyEvent: onKey,
        child: Stack(children: [
          Positioned.fill(child: slides()),
          if (showControls)
            Positioned(top: 0, left: 0, right: 0, child: topBar()),
          if (showControls && listOfImagesInfo.isNotEmpty)
            Positioned(bottom: 0, left: 0, right: 0, child: bottomBar()),
        ]),
      ),
    );
  }

  Widget slides() {
    if (listOfImagesInfo.isEmpty) {
      Widget child;
      if (isLoading) {
        child = const CircularProgressIndicator();
      } else if (loadFailed) {
        child = TextButton.icon(
          onPressed: loadFirstSet,
          icon: const Icon(Icons.refresh),
          label: const Text("Couldn't load the photos. Tap to retry"),
        );
      } else {
        child = const Text('No photos from this date',
            style: TextStyle(color: Colors.white, fontSize: 18));
      }
      return Center(child: child);
    }
    return GestureDetector(
      onTap: () => showControls ? hideControls() : showControlsForAWhile(),
      child: PageView.builder(
        controller: pageController,
        itemCount: listOfImagesInfo.length,
        onPageChanged: onPageChanged,
        itemBuilder: (BuildContext ctx, int index) {
          final Map photo = listOfImagesInfo[index];
          return Image(
            image: fullImage(photo),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              // The small photo until the full one is downloaded
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    shrunkImageUrl(photo),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  const Center(
                      child: CircularProgressIndicator(color: Colors.white70)),
                ],
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
                child:
                    Icon(Icons.broken_image, size: 64, color: Colors.white54)),
          );
        },
      ),
    );
  }

  Widget topBar() {
    String details = '';
    if (listOfImagesInfo.isNotEmpty) {
      final Map photo = listOfImagesInfo[currentIndex];
      final String date = photo['createdDate'] ?? '';
      // "+" while there are more photos still to load
      details = "${currentIndex + 1} / ${listOfImagesInfo.length}"
          "${hasMore ? '+' : ''}   ${date.length >= 16 ? date.substring(0, 16) : date}";
    }
    return Container(
      color: Colors.black45,
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          const BackButton(color: Colors.white),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titles[widget.filter] ?? 'Photos',
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                if (details.isNotEmpty)
                  Text(details,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      color: Colors.black45,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous',
              color: Colors.white,
              iconSize: 36,
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                showPreviousPhoto();
                showControlsForAWhile();
              },
            ),
            IconButton(
              focusNode: playButtonFocus,
              tooltip: playing ? 'Pause' : 'Play',
              color: Colors.white,
              iconSize: 48,
              icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
              onPressed: () => setPlaying(!playing),
            ),
            IconButton(
              tooltip: 'Next',
              color: Colors.white,
              iconSize: 36,
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                showNextPhoto(waitForDownload: false);
                showControlsForAWhile();
              },
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {
                changeInterval();
                showControlsForAWhile();
              },
              icon: const Icon(Icons.timer, color: Colors.white),
              label: Text('${intervalSeconds}s',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            IconButton(
              tooltip: 'Download',
              color: Colors.white,
              iconSize: 32,
              icon: saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download),
              onPressed: () {
                saveCurrentPhoto();
                showControlsForAWhile();
              },
            ),
          ],
        ),
      ),
    );
  }
}
