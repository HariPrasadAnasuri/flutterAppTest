import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'VideoListItem.dart';
import 'model/Video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageVideos extends StatefulWidget {
  const ManageVideos({super.key});

  @override
  State<ManageVideos> createState() => _ManageVideosState();
}
int optionSelected = 0;
class _ManageVideosState extends State<ManageVideos> {
  late Future<List<Video>> _videoListFuture;

  @override
  void initState() {
    super.initState();
      _videoListFuture = VideoProvider.fetchVideos();
    }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Butterfly Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder<List<Video>>(
        future: _videoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load videos'));
          } else {
            final videoList = snapshot.data!;
            return ListView.builder(
              itemCount: videoList.length,
              itemBuilder: (context, index) {
                return VideoListItem(video: videoList[index]);
              },
            );
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        height: 50,
        backgroundColor: Colors.green[100],
        surfaceTintColor: Colors.red,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calendar_today, color: Colors.blue), label: 'Date'),
          NavigationDestination(
              icon: Icon(Icons.refresh, color: Colors.blue), label: 'Refresh'),
        ],
        onDestinationSelected: (int index) async {
          if (index == 0) {
            //_showPopup(context);
            _datePicker(context);
          }
          if (index == 1) {
            _videoListFuture = VideoProvider.fetchVideos();
          }
          setState(() {
            optionSelected = index;
          });
        }
      ),
    );
  }
  void _datePicker(BuildContext context) async{
    DateTime selectedDate;
    if(AppValues.importantPhotosDate.isNotEmpty){
      selectedDate = DateTime.parse(AppValues.importantPhotosDate);
    }else{
      selectedDate = DateTime.now();
    }
    DateTime? pickedDate = await showDatePicker(
        context: context, //context of current state
        initialDate: selectedDate,
        firstDate: DateTime(1990), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );

    if(pickedDate != null ){
      print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
      AppValues.dateForVideos = pickedDate.toString();
      //String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      //print(formattedDate); //formatted date output using intl package =>  2021-03-16
    }else{
      print("Date is not selected");
    }
  }
  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            controller: TextEditingController(text: AppValues.importantPhotosDate),
            //controller: TextEditingController(text: "2013-02-29 14:22:22.0"),

            onChanged: (value) {
              setState(() {
                AppValues.setImportantPhotosDate(value);
              });
            },
            /*decoration: const InputDecoration(
              hintText: 'Type something...',
            ),*/

          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Perform the save operation here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
