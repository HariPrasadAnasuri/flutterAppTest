import 'package:flutter/material.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/ShowVideo.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/show_qr_code_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'app_utility.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _VideosPageState extends State<VideosPage> {
  String textEntered = "";
  String url  = "";
  late String dropdownValue = list.first;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            // decoration: BoxDecoration(
            //   border: Border.all(),
            // ),
            child: Column(children: [
              const SizedBox(height: 33),
              AppUtility.createAnimationButton(
                  "Categorize Videos",
                  Colors.blueAccent,
                  200,
                  MediaQuery.of(context).size.width,
                  const Color.fromARGB(60, 0, 255, 204),
                  const Color.fromARGB(255, 26, 163, 255),
                  40,
                  2, () {
                onCategoriseVideosButtonPressed();
              }),
              const SizedBox(height: 12),
              AppUtility.createAnimationButton(
                  "Chosen Videos",
                  Colors.cyanAccent,
                  200,
                  MediaQuery.of(context).size.width,
                  const Color.fromARGB(40, 60, 27, 109),
                  const Color.fromARGB(255, 239, 70, 27),
                  40,
                  2, () {
                onChosenVideosButtonPressed();
              })
            ]),
          ),
        ));
  }
  void onCategoriseVideosButtonPressed() {
    AppUtility.datePicker(context).then((selectedDate) => {
      if (selectedDate != null)
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext buildContext) {
                return const ShowVideo();
              },
            ),
          )
        }
    });
  }

  void onChosenVideosButtonPressed() {
    AppUtility.datePicker(context).then((selectedDate) => {
      if (selectedDate != null)
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext buildContext) {
                AppValues.dateForVideos = selectedDate.toString();
                debugPrint(
                    "Selected date: ${AppValues.importantPhotosDate}");
                return const ShowVideo();
              },
            ),
          )
        }
    });
  }
}
