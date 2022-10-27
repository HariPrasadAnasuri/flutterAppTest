import 'dart:convert';
import 'dart:ui';

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
  List highlightColors = [];
  var response;
  late int selectedImageId;
  late FixedExtentScrollController controller;
  late String lastDateSelected;
  String selectedListItemColor = "red";

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
      var networkImage = ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          fit: BoxFit.cover,
          urlForImage,
        ),
      );

      debugPrint("urlForImage $urlForImage");
      setState(() {
        highlightColors.add(Colors.blue);
        imgList.add(networkImage);
      });
    }
  }

  void getFileInfoAndUpdateStatus() async {
    String testUrl = '${AppValues.host}/photos/${AppValues.fileId}/fileInfo';
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward),
        onPressed: () {
          //final nextIndex = controller.selectedItem + 1;
          // controller.animateToItem(nextIndex,
          //     duration: const Duration(seconds: 1), curve: Curves.easeInOut);
          AppValues.fileId = selectedImageId;
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
              icon: Icon(Icons.refresh, color: Colors.blue), label: 'Refresh'),
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
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getMarkAsVisitedUrl());
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 2) {
            setState(() {
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getMarkImportantUrl());
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 3) {
            setState(() {
              AppValues.fileId = selectedImageId;
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
      body: ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    debugPrint("Current Image id ${response[index]["id"]}");
                    var currentSelectedItem = response[index];
                    selectedImageId = currentSelectedItem["id"];
                    AppValues.fileId = selectedImageId;
                    debugPrint(
                        "Current selected image index ${currentSelectedItem["id"]}");
                    getFileInfoAndUpdateStatus();
                    String createdDate = currentSelectedItem["createdDate"];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(createdDate),
                        duration: const Duration(milliseconds: 1000),
                      ),
                    );
                    setState(() {
                      highlightColors[index] = Colors.green;
                      for (var i = 0; i < highlightColors.length; i++) {
                        if (i != index) {
                          highlightColors[i] = Colors.blue;
                        }
                      }
                    });
                  },
                  child: Container(
                    child: imgList[index],
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: highlightColors[index], width: 6),
                      borderRadius: BorderRadius.circular(15),
                      // gradient: const LinearGradient(
                      //     begin: Alignment.topRight,
                      //     end: Alignment.bottomLeft,
                      //     colors: [
                      //       Colors.blue,
                      //       Colors.red,
                      //     ]),
                      color: Colors.green,
                      backgroundBlendMode: BlendMode.color,
                    ),
                  ),
                )
                // Icon(
                //   Icons.favorite,
                //   color: Colors.red,
                //   size: 50,
                // ),
              ],
            ),
          );
        },
        itemCount: imgList.length,
      ),
    );
  }
}
