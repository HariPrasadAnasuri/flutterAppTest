import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:video_player/video_player.dart';

import 'model/Video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageVideos extends StatefulWidget {
  const ManageVideos({super.key});

  @override
  State<ManageVideos> createState() => _ManageVideosState();
}

class _ManageVideosState extends State<ManageVideos> {
  List<Video>? videoList;
  VideoPlayerController? _videoPlayerController;
  late ChewieController _chewieController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
    _videoPlayerController?.dispose();
    _chewieController.dispose();
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
          body: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
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
          child: Chewie(
            controller: _chewieController,
          ),
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
    debugPrint("videoList![currentIndex].videoUrl: ${videoList![currentIndex].videoUrl}");

    if(!isItFirtLoad){
      debugPrint("Disposing the video");
      _videoPlayerController?.dispose();
      _chewieController.dispose();

    }
    _videoPlayerController = VideoPlayerController.network(videoList![currentIndex].videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: true,
      zoomAndPan: true,
      //fullScreenByDefault: true,
      //aspectRatio: _videoPlayerController!.value.aspectRatio,
      autoInitialize: true,

      // Add any other Chewie options you need
    );
  }
}
class VideoProvider {
  static Future<List<Video>> fetchVideos() async {
    final response = await http.get(Uri.parse(AppValues.getNextSetOfVideosInfo()));
    if (response.statusCode == 200) {
      List jsonData = [];
      jsonData = json.decode(response.body);
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

