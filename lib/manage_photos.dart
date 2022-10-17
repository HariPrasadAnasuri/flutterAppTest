// ignore_for_file: unnecessary_const, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pinch_zoom_image.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;
//import 'package:localstorage/localstorage.dart';

import 'assets/constants.dart' as constants;

class ManagePhotos extends StatefulWidget {
  const ManagePhotos({super.key});

  @override
  State<ManagePhotos> createState() => _ManagePhotosState();
}

//final LocalStorage storage = LocalStorage('localstorage_app');
List<Container> textArrayElement = [];
List<String> textArray = [];
int currentPageSelected = 0;
PinchZoomImage pinchZoomImage = PinchZoomImage();

class _ManagePhotosState extends State<ManagePhotos> {
  late String noteEntered;
  late String panDirection;
  void getFileInfoAndUpdateStatus() async {
    String testUrl = '${AppValues.host}/photos/${AppValues.index}/fileInfo';
    var url = Uri.parse(testUrl);
    debugPrint("Url to get the file info $url");
    var result = await http.get(url);
    setState(() {
      var response = jsonDecode(result.body);
      int selectedState = 0;
      if (response['tobeDeleted'] != null && response['tobeDeleted']) {
        selectedState = 3;
      } else if (response['important'] != null && response['important']) {
        selectedState = 2;
      } else if (response['visited'] != null && response['visited']) {
        selectedState = 1;
      }

      currentPageSelected = selectedState;
      debugPrint("currentPageSelected: $currentPageSelected");
      debugPrint("result.body: ${result.body}");
    });
  }

  @override
  void initState() {
    super.initState();
    // if (storage.getItem('lastIndex') == null) {
    //   storage.setItem('lastIndex', 0);
    // }
    //AppValues.index = storage.getItem('lastIndex');
    debugPrint("Index in managePhoto: ${AppValues.index}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: pinchZoomImage),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 50,
        backgroundColor: Colors.green[100],
        surfaceTintColor: Colors.red,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.blue),
              label: 'Prev'),
          NavigationDestination(
              icon: Icon(Icons.view_array, color: Colors.blue),
              label: 'Visited'),
          NavigationDestination(
              icon: Icon(Icons.label_important, color: Colors.green),
              label: 'Important'),
          NavigationDestination(
              icon: Icon(Icons.delete, color: Colors.red), label: 'Delete'),
          NavigationDestination(
              icon: Icon(Icons.arrow_forward_ios_sharp, color: Colors.blue),
              label: 'Next'),
        ],
        onDestinationSelected: (int index) async {
          var url;
          if (index == 0) {
            setState(() {
              AppValues.index = --AppValues.index;
              AppValues.imagesUrl = '${constants.photoUrl}${AppValues.index}';
              debugPrint("AppValues.imagesUrl ${AppValues.imagesUrl}");
              pinchZoomImage = PinchZoomImage();
              debugPrint("Index value: ${AppValues.index}");
              //storage.setItem('lastIndex', AppValues.index);
              getFileInfoAndUpdateStatus();
            });
          }
          if (index == 1) {
            setState(() {
              url = Uri.parse(AppValues.getMarkAsVisitedUrl());
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 2) {
            setState(() {
              url = Uri.parse(AppValues.getMarkImportantUrl());
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 3) {
            setState(() {
              url = Uri.parse(AppValues.getMarkAsRemoveUrll());
              debugPrint("URL $url");
            });
            await http.get(url);
          }
          if (index == 1 || index == 2 || index == 3) {
            var toUpdateIndexUrl = Uri.parse(AppValues.getSetCurrentIndexUrl());
            debugPrint("toUpdateIndexUrl $toUpdateIndexUrl");
            await http.get(toUpdateIndexUrl);
          }
          if (index == 4) {
            setState(() {
              AppValues.index = ++AppValues.index;
              AppValues.imagesUrl = '${constants.photoUrl}${AppValues.index}';
              debugPrint("AppValues.imagesUrl ${AppValues.imagesUrl}");
              pinchZoomImage = PinchZoomImage();
              debugPrint("Index value: ${AppValues.index}");
              //storage.setItem('lastIndex', AppValues.index);
              getFileInfoAndUpdateStatus();
            });
          }
          setState(() {
            currentPageSelected = index;
          });
        },
        selectedIndex: currentPageSelected,
      ),
    );
  }
}
