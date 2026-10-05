import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Infinite-scroll paging for the photo lists. The page attaches
/// [scrollController] to its ListView and renders [listOfImagesInfo]; the next
/// set is fetched automatically when the user nears the bottom.
mixin PagedPhotos<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  List listOfImagesInfo = [];
  bool isLoading = false;
  bool hasMore = true;
  bool loadFailed = false;
  // Bumped on reload so responses from an older request are ignored.
  int _generation = 0;

  /// URL of the next set of photos. [lastItem] is the last photo already
  /// shown, or null when loading the first set.
  Uri nextSetUrl(Map? lastItem);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Clears the list and loads it again from the first set.
  Future<void> reloadImages() async {
    _generation++;
    setState(() {
      listOfImagesInfo = [];
      isLoading = false;
      hasMore = true;
      loadFailed = false;
    });
    await _fetchNextSet();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore || loadFailed) return;
    await _fetchNextSet();
  }

  void retryLoad() {
    setState(() => loadFailed = false);
    loadMore();
  }

  void _onScroll() {
    if (scrollController.position.extentAfter < 1000) loadMore();
  }

  Future<void> _fetchNextSet() async {
    final generation = _generation;
    setState(() {
      isLoading = true;
      loadFailed = false;
    });
    try {
      final lastItem = listOfImagesInfo.isEmpty ? null : listOfImagesInfo.last;
      final url = nextSetUrl(lastItem);
      debugPrint("url $url");
      final result = await http.get(url);
      if (result.statusCode != 200) {
        throw Exception('HTTP ${result.statusCode}');
      }
      final List nextSet = jsonDecode(result.body);
      if (!mounted || generation != _generation) return;
      // The next set can overlap the current one (e.g. photos sharing the
      // boundary date), so keep only unseen ids. Nothing new means the end.
      final knownIds = listOfImagesInfo.map((photo) => photo["id"]).toSet();
      final newItems =
          nextSet.where((photo) => !knownIds.contains(photo["id"])).toList();
      setState(() {
        listOfImagesInfo.addAll(newItems);
        hasMore = newItems.isNotEmpty;
        isLoading = false;
      });
      // If the first sets don't fill the screen there is nothing to scroll,
      // so keep loading until they do.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            scrollController.hasClients &&
            scrollController.position.extentAfter < 1000) {
          loadMore();
        }
      });
    } catch (e) {
      debugPrint("Failed to load photos: $e");
      if (!mounted || generation != _generation) return;
      setState(() {
        isLoading = false;
        loadFailed = true;
      });
    }
  }
}

/// Thumbnail used in the photo lists. Keeps a fixed-height placeholder while
/// the image downloads so the list doesn't jump, and shows an icon on failure.
class PhotoListImage extends StatelessWidget {
  const PhotoListImage(
      {super.key, required this.url, this.errorIcon = Icons.broken_image});
  final String url;
  // Shown when the image can't be loaded
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      // Decode at screen width instead of full resolution to keep memory low
      // while many images are in the list.
      cacheWidth: (mediaQuery.size.width * mediaQuery.devicePixelRatio).round(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: total != null ? progress.cumulativeBytesLoaded / total : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => AspectRatio(
        aspectRatio: 4 / 3,
        child: ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(errorIcon, size: 64)),
        ),
      ),
    );
  }
}

/// Last row of a paged photo list: spinner while loading, a retry button
/// after a failure, and an end-of-list message when nothing more is left.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    super.key,
    required this.isLoading,
    required this.hasMore,
    required this.loadFailed,
    required this.onRetry,
    this.itemName = 'photos',
  });
  final bool isLoading;
  final bool hasMore;
  final bool loadFailed;
  final VoidCallback onRetry;
  // Used in the messages, e.g. "No more photos"
  final String itemName;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isLoading) {
      child = const CircularProgressIndicator();
    } else if (loadFailed) {
      child = TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text("Couldn't load more $itemName. Tap to retry"),
      );
    } else if (!hasMore) {
      child = Text('No more $itemName');
    } else {
      child = const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: child),
    );
  }
}
