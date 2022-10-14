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
  void getFileInfo() async {
    String testUrl = '${AppValues.host}/photos/${AppValues.index}/fileInfo';
    var url = Uri.parse(testUrl);
    debugPrint("Url to get the file info $url");
    var result = await http.get(url);
    setState(() {
      var response = jsonDecode(result.body);
      int selectedState = 0;
      if (response['tobeDeleted'] != null && response['tobeDeleted']) {
        selectedState = 2;
      } else if (response['important'] != null && response['important']) {
        selectedState = 1;
      } else if (response['visited'] != null && response['visited']) {
        selectedState = 0;
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
    return WillPopScope(
      child: Scaffold(
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
        body: Column(
          children: [
            Expanded(
                child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      // Note: Sensitivity is integer used when you don't want to mess up vertical drag
                      int threshold = 3;
                      if (details.delta.dx > threshold) {
                        panDirection = "right";
                      }
                      if (details.delta.dx < -threshold) {
                        panDirection = "left";
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      debugPrint("panDirection $panDirection");
                      if (panDirection == 'left') {
                        setState(() {
                          AppValues.index = --AppValues.index;
                          AppValues.imagesUrl =
                              '${constants.photoUrl}${AppValues.index}';
                          debugPrint(
                              "AppValues.imagesUrl ${AppValues.imagesUrl}");
                          pinchZoomImage = PinchZoomImage();
                          debugPrint("Index value: ${AppValues.index}");
                          getFileInfo();
                        });
                      }
                      if (panDirection == 'right') {
                        setState(() {
                          AppValues.index = ++AppValues.index;
                          AppValues.imagesUrl =
                              '${constants.photoUrl}${AppValues.index}';
                          debugPrint(
                              "AppValues.imagesUrl ${AppValues.imagesUrl}");
                          pinchZoomImage = PinchZoomImage();
                          debugPrint("Index value: ${AppValues.index}");
                          getFileInfo();
                        });
                      }
                    },
                    child: pinchZoomImage)),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Align(
            //         alignment: Alignment.bottomLeft,
            //         child: GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               AppValues.index = --AppValues.index;
            //               AppValues.imagesUrl =
            //                   '${constants.photoUrl}${AppValues.index}';
            //               debugPrint(
            //                   "AppValues.imagesUrl ${AppValues.imagesUrl}");
            //               pinchZoomImage = PinchZoomImage();
            //               debugPrint("Index value: ${AppValues.index}");
            //               //storage.setItem('lastIndex', AppValues.index);
            //               getFileInfo();
            //             });
            //           },
            //           child: Container(
            //             decoration: const BoxDecoration(
            //               color: Colors.blue,
            //               borderRadius: BorderRadius.only(
            //                   topRight: Radius.circular(10.0),
            //                   bottomRight: Radius.circular(10.0),
            //                   topLeft: Radius.circular(10.0),
            //                   bottomLeft: Radius.circular(10.0)),
            //             ),
            //             height: 100,
            //             padding: const EdgeInsets.all(16),
            //             // Change button text when light changes state.
            //             child: const Text(
            //               'Prev',
            //               style: TextStyle(color: Colors.yellow, fontSize: 30),
            //             ),
            //           ),
            //         )),
            //     Align(
            //         alignment: Alignment.bottomLeft,
            //         child: GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               AppValues.index = ++AppValues.index;
            //               AppValues.imagesUrl =
            //                   '${constants.photoUrl}${AppValues.index}';
            //               debugPrint(
            //                   "AppValues.imagesUrl ${AppValues.imagesUrl}");
            //               pinchZoomImage = PinchZoomImage();
            //               debugPrint("Index value: ${AppValues.index}");
            //               //storage.setItem('lastIndex', AppValues.index);
            //               getFileInfo();
            //             });
            //           },
            //           child: Container(
            //             decoration: const BoxDecoration(
            //               color: Colors.blue,
            //               borderRadius: BorderRadius.only(
            //                   topRight: Radius.circular(10.0),
            //                   bottomRight: Radius.circular(10.0),
            //                   topLeft: Radius.circular(10.0),
            //                   bottomLeft: Radius.circular(10.0)),
            //             ),
            //             height: 100,
            //             padding: const EdgeInsets.all(16),
            //             // Change button text when light changes state.
            //             child: const Text(
            //               'Next',
            //               style: TextStyle(color: Colors.yellow, fontSize: 30),
            //             ),
            //           ),
            //         )),
            //   ],
            // ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.green[100],
          surfaceTintColor: Colors.red,
          destinations: const [
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
              setState(() {
                url = Uri.parse(AppValues.getMarkAsVisitedUrl());
                debugPrint("URL $url");
              });

              await http.get(url);
            }
            if (index == 1) {
              setState(() {
                url = Uri.parse(AppValues.getMarkImportantUrl());
                debugPrint("URL $url");
              });

              await http.get(url);
            }
            if (index == 2) {
              setState(() {
                url = Uri.parse(AppValues.getMarkAsRemoveUrll());
                debugPrint("URL $url");
              });
              await http.get(url);
            }
            var toUpdateIndexUrl = Uri.parse(AppValues.getSetCurrentIndexUrl());
            debugPrint("toUpdateIndexUrl $toUpdateIndexUrl");
            await http.get(toUpdateIndexUrl);

            setState(() {
              currentPageSelected = index;
            });
          },
          selectedIndex: currentPageSelected,
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
