import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_application_1/app_utility.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/ShowVideo.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/show_qr_code_photo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _PhotosPageState extends State<PhotosPage> {
  String textEntered = "";
  String url = "";
  late String dropdownValue = list.first;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const SizedBox(height: 33),
      AppUtility.createAnimationButton(
          "Categorise Photos",
          Colors.blueAccent,
          200,
          MediaQuery.of(context).size.width,
          const Color.fromARGB(60, 0, 255, 204),
          const Color.fromARGB(255, 26, 163, 255),
          40,
          2, () {
        onCategorisePhotosButtonPressed();
      }),
      const SizedBox(height: 12),
      AppUtility.createAnimationButton(
          "Chosen Photos",
          Colors.cyanAccent,
          200,
          MediaQuery.of(context).size.width,
          const Color.fromARGB(40, 60, 27, 109),
          const Color.fromARGB(255, 239, 70, 27),
          40,
          2, () {
        onChosenPhotosButtonPressed();
      })
    ]));
  }

  void onCategorisePhotosButtonPressed() {
    AppUtility.datePicker(context).then((selectedDate) => {
          if (selectedDate != null)
            {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    return const ListPhotos();
                  },
                ),
              )
            }
        });
  }

  void onChosenPhotosButtonPressed() {
    AppUtility.datePicker(context).then((selectedDate) => {
          if (selectedDate != null)
            {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    AppValues.importantPhotosDate = selectedDate.toString();
                    debugPrint(
                        "Selected date: ${AppValues.importantPhotosDate}");
                    return const SelectedPhotos();
                  },
                ),
              )
            }
        });
  }
}
