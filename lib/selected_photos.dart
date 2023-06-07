import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import 'manage_photos.dart';

class SelectedPhotos extends StatefulWidget {
  const SelectedPhotos({super.key});

  @override
  State<SelectedPhotos> createState() => _SelectedPhotosState();
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
class _SelectedPhotosState extends State<SelectedPhotos> {
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

  Future<bool> initialCalls() async{
    await getTheLastSelectedPhotoInfoForPrint();
    debugPrint("AppValues.importantPhotosDate: ${AppValues.importantPhotosDate}");
    await getsetOfImages();
    controller = FixedExtentScrollController();
    return true;
  }
  Future<bool> getTheLastSelectedPhotoInfoForPrint() async {
    var lastSelectedPhotoUrl = Uri.parse(AppValues.getTheLastSelectedPhotoInfoForPrint());
    var lastSelectedPhotoResponse = await http.get(lastSelectedPhotoUrl);
    AppValues.importantPhotosDate = jsonDecode(lastSelectedPhotoResponse.body)["createdDate"];
    return true;
  }
  Future<List> getsetOfImages() async {
    imgList.clear();
    highlightColors.clear();
    highlightColors.add(Colors.blue);

    debugPrint("Inside getsetOfImages()");
    var url = Uri.parse(AppValues.getNextSetOfImportantImagesInfo());
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

  void downloadFile() async{
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'File Downloading...');
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      //add more permission to request here.
    ].request();

    if(statuses[Permission.storage]!.isGranted){
      var dir = await DownloadsPathProvider.downloadsDirectory;
      if(dir != null){
        String savename = "${AppValues.fileId}.jpg";
        String savePath = dir.path + "/$savename";
        print(savePath);
        //output:  /storage/emulated/0/Download/banner.png

        try {
          await Dio().download(
              AppValues.getImageUrl(),
              savePath,
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  int progress = (received / total * 100).toInt();
                  print(progress.toStringAsFixed(0) + "%");
                  //you can build progressbar feature too
                  pd.update(value: progress, msg: "Completed");
                }
              });
          print("File is saved to download folder.");
        } on DioError catch (e) {
          print(e.message);
        }
      }
    }else{
      print("No permission to read and write.");
    }
  }

  void getFileInfoAndUpdateStatus(currentSelectedItem) async {
    setState(() {
      int selectedState = 0;
      if (currentSelectedItem['printStatus'] != null && currentSelectedItem['printStatus']) {
        if(currentSelectedItem['printStatus'] == "INITIAL"){
          selectedState = 1;
        }else if(currentSelectedItem['printStatus'] == "SELECTED"){
          selectedState = 2;
        }else if(currentSelectedItem['printStatus'] == "PRINTED"){
          selectedState = 3;
        }
      }
      optionSelected = selectedState;
      debugPrint("optionSelected: $optionSelected");
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint("initState");
    initialCalls();
  }



  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: Icon(Icons.calendar_today, color: Colors.blue), label: 'Date'),
          NavigationDestination(
              icon: Icon(Icons.refresh, color: Colors.blue), label: 'Refresh'),
          NavigationDestination(
              icon: Icon(Icons.start, color: Colors.blue),
              label: 'Initial'),
          NavigationDestination(
              icon: Icon(Icons.add, color: Colors.green),
              label: 'Selected'),
          NavigationDestination(
              icon: Icon(Icons.print, color: Colors.red), label: 'Printed'),
        ],
        onDestinationSelected: (int index) async {
          var url;

          if (index == 0) {
            //_showPopup(context);
            _datePicker(context);
          }
          if (index == 1) {
            getsetOfImages();
          }
          if (index == 2) {
            setState(() {
              listOfImagesInfo[currentListIndexSelected]["printStatus"] = "INITIAL";
              AppValues.fileId = selectedImageId;

              url = Uri.parse(AppValues.getUrlToSetThePhotoPrintStatus("INITIAL"));
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 3) {
            setState(() {
              listOfImagesInfo[currentListIndexSelected]["printStatus"] = "SELECTED";
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getUrlToSetThePhotoPrintStatus("SELECTED"));
              debugPrint("URL $url");
            });

            await http.get(url);
          }
          if (index == 4) {
            setState(() {
              listOfImagesInfo[currentListIndexSelected]["printStatus"] = "PRINTED";
              AppValues.fileId = selectedImageId;
              url = Uri.parse(AppValues.getUrlToSetThePhotoPrintStatus("PRINTED"));
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
                          AppValues.importantPhotosDate = listOfImagesInfo[currentListIndexSelected]["createdDate"];
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
                                AppValues.getImageShrunkUrlUsingIdForImportantPhotos(
                                    listOfImagesInfo[index]["id"].toString()),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              //give the values according to your requirement

                              child: RadiantGradientMask(
                                start: (listOfImagesInfo[index]["printStatus"] == "INITIAL")
                                    ? Colors.lightGreenAccent
                                    : (listOfImagesInfo[index]["printStatus"] == "SELECTED")
                                    ? Colors.lightBlue
                                    : (listOfImagesInfo[index]["printStatus"] == "PRINTED")
                                    ? Colors.redAccent
                                    : Colors.yellow,
                                end: Colors.pink,
                                child: Icon(
                                  size: 70,
                                  (listOfImagesInfo[index]["printStatus"] == "INITIAL")
                                      ? Icons.start
                                      : (listOfImagesInfo[index]["printStatus"] == "SELECTED")
                                      ? Icons.add
                                      : (listOfImagesInfo[index]["printStatus"] == "PRINTED")
                                      ? Icons.print
                                      : Icons.pending,
                                  color: (listOfImagesInfo[index]["printStatus"] == "INITIAL")
                                      ? Colors.lightGreenAccent
                                      : (listOfImagesInfo[index]["printStatus"] == "SELECTED")
                                      ? Colors.lightBlue
                                      : (listOfImagesInfo[index]["printStatus"] == "PRINTED")
                                      ? Colors.redAccent
                                      : Colors.yellow,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 300,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add your button action here
                                  print('Button pressed!');
                                  downloadFile();
                                },
                                child: Text('Download'),
                              ),
                            )
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
      AppValues.setImportantPhotosDate(pickedDate.toString());
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
