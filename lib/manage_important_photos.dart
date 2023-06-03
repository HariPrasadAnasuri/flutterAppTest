// ignore_for_file: unnecessary_const, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pinch_zoom_image.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;
//import 'package:localstorage/localstorage.dart';

import 'assets/constants.dart' as constants;

class ManageImportantPhotos extends StatefulWidget {
  const ManageImportantPhotos({super.key});

  @override
  State<ManageImportantPhotos> createState() => _ManageImportantPhotosState();
}

//final LocalStorage storage = LocalStorage('localstorage_app');
List<Container> textArrayElement = [];
List<String> textArray = [];
int currentPageSelected = 0;
PinchZoomImage pinchZoomImage = PinchZoomImage();

class _ManageImportantPhotosState extends State<ManageImportantPhotos> {
  late String noteEntered;
  late String panDirection;
  void getFileInfoAndUpdateStatus() async {
    String testUrl = '${AppValues.host}/photos/${AppValues.fileId}/fileInfo';
    var url = Uri.parse(testUrl);
    debugPrint("Url to get the file info $url");
    var result = await http.get(url);
    setState(() {
      var response = jsonDecode(result.body);
      int selectedState = 0;
      if (response['printStatus'] != null && response['printStatus']) {
        if(response['printStatus'] == "INITIAL"){
          selectedState = 1;
        }else if(response['printStatus'] == "SELECTED"){
          selectedState = 2;
        }else if(response['printStatus'] == "PRINTED"){
          selectedState = 3;
        }
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
    debugPrint("Index in managePhoto: ${AppValues.fileId}");
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
              icon: Icon(Icons.face, color: Colors.blue), label: 'Dummy'),
          NavigationDestination(
              icon: Icon(Icons.view_array, color: Colors.blue),
              label: 'Initial'),
          NavigationDestination(
              icon: Icon(Icons.label_important, color: Colors.green),
              label: 'Selected'),
          NavigationDestination(
              icon: Icon(Icons.delete, color: Colors.red), label: 'Printed'),
          // NavigationDestination(
          //     icon: Icon(Icons.arrow_forward_ios_sharp, color: Colors.blue),
          //     label: 'Next'),
        ],
        onDestinationSelected: (int index) async {
          var url;
          if (index == 0) {
            // setState(() {
            //   AppValues.index = --AppValues.index;
            //   AppValues.imagesUrl = '${constants.photoUrl}${AppValues.index}';
            //   debugPrint("AppValues.imagesUrl ${AppValues.imagesUrl}");
            //   pinchZoomImage = PinchZoomImage();
            //   debugPrint("Index value: ${AppValues.index}");
            //   //storage.setItem('lastIndex', AppValues.index);
            //   getFileInfoAndUpdateStatus();
            // });
          }
          if (index == 1) {
            setState(() {
              url = Uri.parse(AppValues.getUrlToSetThePhotoPrintStatus("INITIAL"));
              debugPrint("URL $url");
            });
            await http.get(url);
          }
          if (index == 2) {
            setState(() {
              url = Uri.parse(AppValues.getUrlToSetThePhotoPrintStatus("SELECTED"));
              debugPrint("URL $url");
            });
            await http.get(url);
          }
          if (index == 3) {
            setState(() {
              url = Uri.parse(AppValues.getUrlToSetThePhotoPrintStatus("PRINTED"));
              debugPrint("URL $url");
            });
            await http.get(url);
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
