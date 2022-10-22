import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;

import 'manage_photos.dart';

class ListPhotos extends StatefulWidget {
  const ListPhotos({super.key});

  @override
  State<ListPhotos> createState() => _ListPhotosState();
}

int currentPageSelected = 0;

class _ListPhotosState extends State<ListPhotos> {
  List imgList = [];
  var response;
  late int selectedImageId;
  late FixedExtentScrollController controller;
  late String lastDateSelected;

  void getsetOfImages() async {
    imgList = [];
    debugPrint("Inside getsetOfImages()");
    var url = Uri.parse(AppValues.getNextSetOfImagesInfo());
    debugPrint("url $url");
    var result = await http.get(url);
    response = jsonDecode(result.body);
    debugPrint("response $response");
    for (var i = 0; i < response.length; i++) {
      var imageId = response[i]["id"];
      var urlForImage = AppValues.getImageShrunkUrlUsingIndex(imageId);
      var networkImage = Image.network(fit: BoxFit.cover, urlForImage);

      debugPrint("urlForImage $urlForImage");
      setState(() {
        imgList.add(networkImage);
      });
    }
  }

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
    getsetOfImages();

    controller = FixedExtentScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  double get minScrollExtent => _minScrollExtent;
  double _minScrollExtent = 0.0;

  @override
  double get maxScrollExtent => _maxScrollExtent;
  double _maxScrollExtent = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_forward),
          onPressed: () {
            //final nextIndex = controller.selectedItem + 1;
            // controller.animateToItem(nextIndex,
            //     duration: const Duration(seconds: 1), curve: Curves.easeInOut);
            AppValues.index = selectedImageId;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext buildContext) {
                  return const ManagePhotos();
                },
              ),
            );
          },
        ),
        bottomNavigationBar: NavigationBar(
          height: 50,
          backgroundColor: Colors.green[100],
          surfaceTintColor: Colors.red,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.refresh, color: Colors.blue),
                label: 'Refresh'),
            NavigationDestination(
                icon: Icon(Icons.view_array, color: Colors.blue),
                label: 'Visited'),
            NavigationDestination(
                icon: Icon(Icons.label_important, color: Colors.green),
                label: 'Important'),
            NavigationDestination(
                icon: Icon(Icons.delete, color: Colors.red), label: 'Delete'),
          ],
          onDestinationSelected: (int index) async {
            var url;
            if (index == 0) {
              getsetOfImages();
            }
            if (index == 1) {
              setState(() {
                AppValues.index = selectedImageId;
                url = Uri.parse(AppValues.getMarkAsVisitedUrl());
                debugPrint("URL $url");
              });

              await http.get(url);
            }
            if (index == 2) {
              setState(() {
                AppValues.index = selectedImageId;
                url = Uri.parse(AppValues.getMarkImportantUrl());
                debugPrint("URL $url");
              });

              await http.get(url);
            }
            if (index == 3) {
              setState(() {
                AppValues.index = selectedImageId;
                url = Uri.parse(AppValues.getMarkAsRemoveUrll());
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
        body: ListWheelScrollView.useDelegate(
          itemExtent: 250,
          //magnification: 2,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.001,
          diameterRatio: 1.5,
          onSelectedItemChanged: (index) {
            var currentSelectedItem = response[index];
            selectedImageId = currentSelectedItem["id"];
            AppValues.index = selectedImageId;
            debugPrint(
                "Current selected image index ${currentSelectedItem["id"]}");
            getFileInfoAndUpdateStatus();
          },

          controller: controller,
          squeeze: 1.1,
          //offAxisFraction: 1.5,
          childDelegate: ListWheelChildBuilderDelegate(
              childCount: imgList.length,
              builder: (context, index) => imgList[index]),
        ));
  }
}
