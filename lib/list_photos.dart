import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;

import 'show_photo.dart';

class ListPhotos extends StatefulWidget {
  const ListPhotos({super.key});

  @override
  State<ListPhotos> createState() => _ListPhotosState();
}

int optionSelected = 0;

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({super.key, required this.child, required this.start, required this.end});
  final Widget child;
  final Color start;
  final Color end;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.bottomLeft,
        radius: 0.5,
        colors: [start, end],
        tileMode: TileMode.repeated,
      ).createShader(bounds),
      child: child,
    );
  }
}
class _ListPhotosState extends State<ListPhotos> {
  List imgList = [];
  List highlightColors = [];
  late int currentListIndexSelected;
  List listOfImagesInfo = [];
  late int selectedImageId;
  late FixedExtentScrollController controller;
  late String lastDateSelected;
  String selectedListItemColor = "red";
  IconData testIcon = Icons.favorite;
  int _currentMax = 10;

  _getMoreData() {
    for (int i = _currentMax; i < _currentMax + 10; i++) {
      listOfImagesInfo.add("Item : ${i + 1}");
    }

    _currentMax = _currentMax + 10;

    setState(() {});
  }

  Future<List> getsetOfImages() async {
    imgList.clear();
    highlightColors.clear();
    highlightColors.add(Colors.blue);
    debugPrint("Inside getsetOfImages()");
    var url = Uri.parse(AppValues.getNextSetOfImagesInfo());
    debugPrint("url $url");
    var result = await http.get(url);
    listOfImagesInfo = jsonDecode(result.body);
    //debugPrint("response $response");
    for (var i = 0; i < listOfImagesInfo.length; i++) {
      setState(() {
        highlightColors.add(Colors.blue);
      });
    }
    return listOfImagesInfo;
  }

  void getFileInfoAndUpdateStatus(currentSelectedItem) async {
    setState(() {
      int selectedState = 0;
      if (currentSelectedItem['tobeDeleted'] != null && currentSelectedItem['tobeDeleted']) {
        selectedState = 4;
      } else if (currentSelectedItem['important'] != null && currentSelectedItem['important']) {
        selectedState = 3;
      } else if (currentSelectedItem['visited'] != null && currentSelectedItem['visited']) {
        selectedState = 2;
      }
      optionSelected = selectedState;
      debugPrint("optionSelected: $optionSelected");
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
      appBar: AppBar(
        title: const Text('Harsha game'),
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
      backgroundColor: Colors.grey,
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
                return const ShowPhoto();
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
              icon: Icon(Icons.face, color: Colors.blue), label: 'Dummy'),
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

          }
          if (index == 1) {
            getsetOfImages();
          }
          if (index == 2) {
            setState(() {
              listOfImagesInfo[currentListIndexSelected]["visited"] = true;
              listOfImagesInfo[currentListIndexSelected]["tobeDeleted"] = false;
              listOfImagesInfo[currentListIndexSelected]["important"] = false;
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getMarkAsVisitedUrl());
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 3) {
            setState(() {
              listOfImagesInfo[currentListIndexSelected]["important"] = true;
              listOfImagesInfo[currentListIndexSelected]["visited"] = false;
              listOfImagesInfo[currentListIndexSelected]["tobeDeleted"] = false;
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getMarkImportantUrl());
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 4) {
            setState(() {
              listOfImagesInfo[currentListIndexSelected]["tobeDeleted"] = true;
              listOfImagesInfo[currentListIndexSelected]["important"] = false;
              listOfImagesInfo[currentListIndexSelected]["visited"] = false;
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getMarkAsRemoveUrll());
              debugPrint("URL $url");
            });
            await http.get(url);
          }
          setState(() {
            optionSelected = index;
          });
        },
        selectedIndex: optionSelected,
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          if(highlightColors.length > 5){
            return
              Padding(
                padding: const EdgeInsets.all(3),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        debugPrint("Current Image id ${listOfImagesInfo[index]["id"]}");
                        var currentSelectedItem = listOfImagesInfo[index];
                        selectedImageId = currentSelectedItem["id"];
                        AppValues.fileId = selectedImageId;
                        debugPrint(
                            "Current selected image index ${currentSelectedItem["id"]}");
                        getFileInfoAndUpdateStatus(currentSelectedItem);
                        String createdDate = currentSelectedItem["createdDate"];
                        String fileLocation = currentSelectedItem["filePath"];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$createdDate\n$fileLocation"),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                        setState(() {
                          currentListIndexSelected = index;
                          highlightColors[index] = Colors.green;
                          for (var i = 0; i < highlightColors.length; i++) {
                            if (i != index) {
                              highlightColors[i] = Colors.blue;
                            }
                          }
                        });
                      },
                      child: Container(
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
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                fit: BoxFit.cover,
                                AppValues.getImageShrunkUrlUsingIndex(
                                    listOfImagesInfo[index]["id"].toString()),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              //give the values according to your requirement
                              
                              child: RadiantGradientMask(
                                start: listOfImagesInfo[index]["important"]
                                    ? Colors.lightGreenAccent
                                    : listOfImagesInfo[index]["visited"]
                                    ? Colors.lightBlue
                                    : listOfImagesInfo[index]["tobeDeleted"]
                                    ? Colors.redAccent
                                    : Colors.yellow,
                                end: Colors.pink,
                                child: Icon(
                                  size: 70,
                                  listOfImagesInfo[index]["important"]
                                      ? Icons.favorite
                                      : listOfImagesInfo[index]["visited"]
                                      ? Icons.view_array
                                      : listOfImagesInfo[index]["tobeDeleted"]
                                      ? Icons.delete
                                      : Icons.pending,
                                  color: listOfImagesInfo[index]["important"]
                                      ? Colors.lightGreenAccent
                                      : listOfImagesInfo[index]["visited"]
                                      ? Colors.lightBlue
                                      : listOfImagesInfo[index]["tobeDeleted"]
                                      ? Colors.redAccent
                                      : Colors.yellow,
                                ),
                              ),
                            ),
                          ],
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
          }else{
            return const CircularProgressIndicator();
          }

        },
        itemCount: listOfImagesInfo.length,
      ),
    );
  }
}