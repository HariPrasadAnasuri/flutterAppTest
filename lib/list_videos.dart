import 'package:flutter/material.dart';
import 'package:flutter_application_1/ShowVideo.dart';
import 'package:flutter_application_1/paged_photo_list.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/video_status.dart';

/// Scrollable list of videos from [startDate] on, loading more while
/// scrolling. Tap a video to select it and mark it with the bottom bar, tap
/// its play button (or double tap) to watch it.
class ListVideos extends StatefulWidget {
  const ListVideos(
      {super.key,
      required this.startDate,
      required this.filter,
      required this.title});
  final String startDate;
  // 'notReviewed' or 'important', see AppValues.getNextSetOfVideosUrl
  final String filter;
  final String title;

  @override
  State<ListVideos> createState() => _ListVideosState();
}

class _ListVideosState extends State<ListVideos> with PagedPhotos {
  int? selectedIndex;

  @override
  Uri nextSetUrl(Map? lastItem) {
    // The server returns the videos after the given date, so continue from
    // the last one in the list.
    final String fromDate =
        lastItem == null ? widget.startDate : lastItem['createdDate'];
    return Uri.parse(AppValues.getNextSetOfVideosUrl(fromDate, widget.filter));
  }

  @override
  void initState() {
    super.initState();
    reloadImages();
  }

  Future<void> refresh() async {
    selectedIndex = null;
    await reloadImages();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), duration: const Duration(milliseconds: 1500)),
    );
  }

  void select(int index) {
    final Map video = listOfImagesInfo[index];
    setState(() => selectedIndex = index);
    showMessage("${video['createdDate']}\n${video['filePath']}");
  }

  Future<void> play(int index) async {
    setState(() => selectedIndex = index);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return ShowVideo(
            videos: listOfImagesInfo,
            initialIndex: index,
            // Keep the video that is playing selected here too
            onIndexChanged: (newIndex) => selectedIndex = newIndex,
          );
        },
      ),
    );
    // Show the marks made in the player
    if (mounted) setState(() {});
  }

  Future<void> mark(String action) async {
    final index = selectedIndex;
    if (index == null) {
      showMessage("Tap a video to select it first");
      return;
    }
    try {
      await VideoStatus.mark(listOfImagesInfo[index], action);
    } catch (e) {
      debugPrint("Failed to mark video: $e");
      if (mounted) showMessage("Couldn't save, please try again");
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map? selectedVideo =
        selectedIndex == null ? null : listOfImagesInfo[selectedIndex!];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: refresh,
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh))
        ],
      ),
      backgroundColor: Colors.grey,
      bottomNavigationBar: VideoMarkBar(video: selectedVideo, onMark: mark),
      body: ListView.builder(
        controller: scrollController,
        // One extra row for the loading / end-of-list footer.
        itemCount: listOfImagesInfo.length + 1,
        itemBuilder: (BuildContext ctx, int index) {
          if (index == listOfImagesInfo.length) {
            return LoadMoreFooter(
              isLoading: isLoading,
              hasMore: hasMore,
              loadFailed: loadFailed,
              onRetry: retryLoad,
              itemName: 'videos',
            );
          }
          return videoCard(index);
        },
      ),
    );
  }

  Widget videoCard(int index) {
    final Map video = listOfImagesInfo[index];
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () => select(index),
        onDoubleTap: () => play(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: index == selectedIndex ? Colors.green : Colors.blue,
                width: 6),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PhotoListImage(
                  url: AppValues.getVideoThumbnailUrl(video['id']),
                  errorIcon: Icons.movie,
                ),
                IconButton(
                  iconSize: 72,
                  color: Colors.white70,
                  tooltip: 'Play',
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: () => play(index),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: VideoStatusIcon(video: video),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${video['fileName']}\n${VideoStatus.dateText(video)}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
