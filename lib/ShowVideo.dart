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
          child: Align(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(
                controller: _chewieController,
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

