import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';

import 'model/Video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowVideo extends StatefulWidget {
  const ShowVideo({super.key});

  @override
  State<ShowVideo> createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  List<Video>? videoList;
  late BetterPlayerController _chewieController;
  int currentIndex = 0;
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
    VideoProvider.fetchVideos().then((videos) {
      setState(() {
        debugPrint("Setting videos:${videos?.length}");
        videoList = videos;
        setVideo(currentIndex,true);
      });
    });
  }

  @override
  void dispose() {
    // Ensure disposig of the VideoPlayerController to free up resources.

    _chewieController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoList == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return
        Scaffold(
          backgroundColor: Colors.grey,
          floatingActionButton: _isZoomed
              ? FloatingActionButton.small(
                  onPressed: _resetZoom,
                  tooltip: 'Reset zoom',
                  child: const Icon(Icons.zoom_out_map),
                )
              : null,
          body: GestureDetector(
          // While zoomed, one-finger drags pan the video instead of
          // switching to the next/previous one.
          onHorizontalDragEnd: _isZoomed ? null : (DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              // Swiped left, play next video
              if (currentIndex < videoList!.length - 1) {
                playNewVideo(currentIndex + 1, true);
              }
            } else if (details.primaryVelocity! > 0) {
              // Swiped right, play previous video
              if (currentIndex > 0) {
                playNewVideo(currentIndex - 1, false);
              }
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
                  controller: _chewieController,
                ),
              ),
            ),
          )
      ),
        );
    }
  }
  void playNewVideo(int newIndex, bool isNext) {
    setState(() {
      if(newIndex == (videoList!.length -1)){
        if(isNext){
          debugPrint("Getting next set");
          AppValues.dateForVideos = videoList![videoList!.length-1].createdDate;
          VideoProvider.fetchVideos().then((videos) {
            videoList = videos;
          });
        }else{
          debugPrint("Getting previous set");
          AppValues.dateForVideos = videoList![videoList!.length-1].createdDate;
          VideoProvider.fetchVideos().then((videos) {
            videoList = videos;
          });
        }
        currentIndex = 0;
        setVideo(currentIndex, false);
      }else{
        debugPrint("Setting next video");
        setVideo(newIndex, false);
      }
    });
  }
  void setVideo(int newIndex, isItFirtLoad){
    currentIndex = newIndex;
    _resetZoom();
    debugPrint("videoList![currentIndex].videoUrl: ${videoList![currentIndex].videoUrl}");

    if(!isItFirtLoad){
      debugPrint("Disposing the video");
      _chewieController.pause();
      _chewieController.dispose();
    }
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoList![currentIndex].videoUrl
    );
    _chewieController = BetterPlayerController(
        const BetterPlayerConfiguration(
          allowedScreenSleep: false,
          autoPlay: true,
          aspectRatio: 16 / 9,
          fit: BoxFit.fitHeight,
          expandToFill: true
        ),
        betterPlayerDataSource: betterPlayerDataSource
    );
  }
}
class VideoProvider {
  static Future<List<Video>> fetchVideos() async {
    final response = await http.get(Uri.parse(AppValues.getNextSetOfVideosInfo()));
    if (response.statusCode == 200) {
      List jsonData = [];
      jsonData = json.decode(response.body);
      //debugPrint("jsonData $jsonData");
      AppValues.dateForVideos = jsonData[jsonData.length -1]["createdDate"];
      return List<Video>.from(jsonData.map((video) => Video(
        title: video['fileName'],
        videoUrl: AppValues.getUrlForVideo(video['id']),
        createdDate: video['createdDate'],
      )));

    } else {
      throw Exception('Failed to fetch videos');
    }
  }
}

