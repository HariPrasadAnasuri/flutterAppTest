import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_application_1/file_structure_page.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/ShowVideo.dart';
import 'package:flutter_application_1/photos_page.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/show_qr_code_photo.dart';
import 'package:flutter_application_1/videos_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'app_utility.dart';

class TvController extends StatefulWidget {
  const TvController({super.key});

  @override
  State<TvController> createState() => _TvControllerState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _TvControllerState extends State<TvController> {
  String textEntered = "";
  String url = "";
  late String dropdownValue = list.first;

  @override
  void initState() {
    super.initState();
    setIpv6Address();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            alignment: AlignmentGeometry.lerp(
                Alignment.topCenter, Alignment.topCenter, 100),
            padding: const EdgeInsets.all(8.0),
            // decoration: BoxDecoration(
            //   border: Border.all(),
            // ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 12),

              AppUtility.createAnimationButton(
                  "Previous",
                  Colors.blueGrey,
                  200,
                  MediaQuery.of(context).size.width,
                  const Color.fromARGB(60, 0, 255, 204),
                  const Color.fromARGB(255, 26, 163, 255),
                  40,
                  2, () {
                previousButtonPressed();
              }),
              const SizedBox(height: 12),

              AppUtility.createAnimationButton(
                  "Next",
                  Colors.blueGrey,
                  200,
                  MediaQuery.of(context).size.width,
                  const Color.fromARGB(60, 0, 255, 204),
                  const Color.fromARGB(255, 26, 163, 255),
                  40,
                  2, () {
                nextButtonPressed();
              }),
              const SizedBox(height: 12),

              AppUtility.createAnimationButton(
                  "Set Date",
                  Colors.blueGrey,
                  200,
                  MediaQuery.of(context).size.width,
                  const Color.fromARGB(60, 0, 255, 204),
                  const Color.fromARGB(255, 26, 163, 255),
                  40,
                  2, () {
                _datePicker(context);
              }),
            ]),
          ),
        ));
  }

  void previousButtonPressed() {
    http.get(Uri.parse(AppValues.getTvControlPreviousApiUrl()));
  }
  void nextButtonPressed() {
    http.get(Uri.parse(AppValues.getTvControlNextApiUrl()));
  }

  void _datePicker(BuildContext context) async{
    DateTime selectedDate;
    if(AppValues.dateForVideos.isNotEmpty){
      selectedDate = DateTime.parse(AppValues.dateForVideos);
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
      //debugPrint(pickedDate.toString());  //pickedDate output format => 2021-03-10 00:00:00.000
      //String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(pickedDate.toLocal());
      AppValues.dateForVideos = pickedDate.toIso8601String();
      debugPrint("AppValues.dateForVideos ${AppValues.dateForVideos}");
      await http.get(Uri.parse(AppValues.setTvControlDateApiUrl()));
    }else{
      debugPrint("Date is not selected");
    }
  }

  void setIpv6Address() async {
    Map<String, String> headers = {
      'Authorization':
      'Bearer 2PJqDIbR1I76Jb3BijggUe0HJEy_41HZk6aT2WsJzt395DdSV',
      'ngrok-version': '2'
    };
    String ngrokUrl;
    var response =
    await http.get(Uri.parse(AppValues.getNgrokApiUrl()), headers: headers);
    if (response.statusCode == 200) {
      ngrokUrl = jsonDecode(response.body)['tunnels'][0]['public_url'];
      debugPrint("ngrokUrl: $ngrokUrl");
    } else {
      throw Exception('Failed to fetch ipv6 address');
    }

    final ipv6Response = await http
        .get(Uri.parse("$ngrokUrl/alexa-voice-monkey/getIpv6Address"));
    if (response.statusCode == 200) {
      debugPrint("Ipv6 Address: ${ipv6Response.body}");
      AppValues.ipv6Address = ipv6Response.body;
    } else {
      throw Exception('Failed to fetch ipv6 address');
    }
  }
}
