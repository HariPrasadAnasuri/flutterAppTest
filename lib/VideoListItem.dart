import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'model/Video.dart';

class VideoListItem extends StatefulWidget {
  final Video video;

  VideoListItem({required this.video});

  @override
  _VideoListItemState createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.network(widget.video.videoUrl);

    // Initialize the VideoPlayerController and load the first frame
    /*videoPlayerController.initialize().then((_) {
      setState(() {
        videoPlayerController.setVolume(0); // Mute the video
        videoPlayerController.play(); // Start playing the video
        videoPlayerController.pause(); // Pause the video after loading the first frame
        _chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: false,
          looping: false,
          showControls: false, // Hide controls since we only want to display the first frame
          placeholder: Container( // Placeholder widget to display the first frame
            color: Colors.black,
            child: VideoPlayer(videoPlayerController),
          ),
        );
      });
    });*/
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      //showControls: false,
      allowedScreenSleep: false,
    );
  }

  @override
  void dispose() {
    debugPrint("Inside video item dispose");
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.video.title),
          Chewie(controller: _chewieController),
        ],
      ),
    );
  }
}
