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
import 'dart:convert';

import 'app_utility.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _HomePageState extends State<HomePage> {
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
              "Photos",
              Colors.blueGrey,
              200,
              MediaQuery.of(context).size.width,
              const Color.fromARGB(60, 0, 255, 204),
              const Color.fromARGB(255, 26, 163, 255),
              80,
              2, () {
            onPhotosButtonPressed();
          }),
          const SizedBox(height: 12),
          AppUtility.createAnimationButton(
              "Videos",
              Colors.blue,
              200,
              MediaQuery.of(context).size.width,
              const Color.fromARGB(255, 26, 163, 255),
              const Color.fromARGB(60, 0, 255, 204),
              80,
              2, () {
            onVideoButtonPressed();
          }),
          const SizedBox(height: 12),
          AppUtility.createAnimationButton(
              "File Structure",
              Colors.blueGrey,
              200,
              MediaQuery.of(context).size.width,
              const Color.fromARGB(60, 0, 255, 204),
              const Color.fromARGB(255, 26, 163, 255),
              40,
              2, () {
            onFileStructureButtonPressed();
          }),
        ]),
      ),
    ));
  }

  void onVideoButtonPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return const VideosPage();
        },
      ),
    );
  }

  void onPhotosButtonPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return const PhotosPage();
        },
      ),
    );
  }

  void onFileStructureButtonPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return const FileStructurePage();
        },
      ),
    );
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
