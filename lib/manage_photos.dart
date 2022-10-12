// ignore_for_file: unnecessary_const, prefer_interpolation_to_compose_strings

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pinch_zoom_image.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;

import 'assets/constants.dart' as constants;

class ManagePhotos extends StatefulWidget {
  const ManagePhotos({super.key});

  @override
  State<ManagePhotos> createState() => _ManagePhotosState();
}

List<Container> textArrayElement = [];
List<String> textArray = [];
int currentPageSelected = 0;
PinchZoomImage pinchZoomImage = PinchZoomImage();

class _ManagePhotosState extends State<ManagePhotos> {
  late String noteEntered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage photos'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
              onPressed: () {
                debugPrint("Actions");
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Center(
        child: pinchZoomImage,
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.navigate_before_rounded), label: 'Prev'),
          NavigationDestination(icon: Icon(Icons.view_array), label: 'Visited'),
          NavigationDestination(
              icon: Icon(Icons.label_important), label: 'Important'),
          NavigationDestination(icon: Icon(Icons.delete), label: 'Delete'),
          NavigationDestination(
              icon: Icon(Icons.navigate_next_rounded), label: 'Next')
        ],
        onDestinationSelected: (int index) async {
          setState(() {
            currentPageSelected = index;
            if (index == 4) {
              AppValues.index = ++AppValues.index;
              AppValues.imagesUrl = '${constants.photoUrl}${AppValues.index}';
              debugPrint("AppValues.imagesUrl ${AppValues.imagesUrl}");
            }
            if (index == 0) {
              AppValues.index = --AppValues.index;
              AppValues.imagesUrl = '${constants.photoUrl}${AppValues.index}';
              debugPrint("AppValues.imagesUrl ${AppValues.imagesUrl}");
            }
            pinchZoomImage = PinchZoomImage();
            debugPrint("Index value: ${AppValues.index}");
          });
          if (index == 1) {
            var url = Uri.parse(AppValues.markAsVisitedUrl);
            debugPrint("URL $url");
            await http.get(url);
          }
          if (index == 2) {
            var url = Uri.parse(AppValues.markAsImportantUrl);
            debugPrint("URL $url");
            await http.get(url);
          }
          if (index == 3) {
            var url = Uri.parse(AppValues.markAsRemoveUrl);
            debugPrint("URL $url");
            await http.get(url);
          }
        },
        selectedIndex: currentPageSelected,
      ),
    );
  }
}
