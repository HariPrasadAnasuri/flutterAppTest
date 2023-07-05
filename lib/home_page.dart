import 'package:flutter/material.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/manage_videos.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/show_qr_code_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _HomePageState extends State<HomePage> {
  String textEntered = "";
  String url  = "";
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
        padding: const EdgeInsets.all(8.0),
        // decoration: BoxDecoration(
        //   border: Border.all(),
        // ),
        child: Column(children: [
          DropdownButton<String>(
            autofocus: true,
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
                debugPrint("sayEntered: $dropdownValue");
                AppValues.userName = dropdownValue;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                AppValues.setSiteUrl(value);
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a search term',
            ),
          ),
          /*const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    return const LearnFlutterPage();
                  },
                ),
              );
            },
            child: const Text('Learn Flutter'),
          ),*/
          /*const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    return const HarshaTask();
                  },
                ),
              );
            },
            child: const Text('Create harsha task'),
          ),*/
          /*const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    return const AlexaVoiceSays();
                  },
                ),
              );
            },
            child: const Text('Alexa voices'),
          ),*/
          /*const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              if (dropdownValue.isNotEmpty) {
                AppValues.userName = dropdownValue;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const ManagePhotos();
                    },
                  ),
                );
              } else {
                debugPrint("Please enter the name");
              }
            },
            child: const Text('Manage photos'),
          ),*/
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              if (dropdownValue.isNotEmpty) {
                AppValues.userName = dropdownValue;
                debugPrint("Going for list photos");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const ListPhotos();
                    },
                  ),
                );
              } else {
                debugPrint("Please enter the name");
              }
            },
            child: const Text('List photos'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              if (dropdownValue.isNotEmpty) {
                AppValues.userName = dropdownValue;
                debugPrint("Going for list photos");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const SelectedPhotos();
                    },
                  ),
                );
              } else {
                debugPrint("");
              }
            },
            child: const Text('Selected photos'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              if (dropdownValue.isNotEmpty) {
                AppValues.userName = dropdownValue;
                debugPrint("Will play video");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const ManageVideos();
                    },
                  ),
                );
              } else {
                debugPrint("");
              }
            },
            child: const Text('Manage videos'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              if (dropdownValue.isNotEmpty) {
                AppValues.userName = dropdownValue;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const ShowQrCodePhoto();
                    },
                  ),
                );
              } else {
                debugPrint("");
              }
            },
            child: const Text('QR code scanner'),
          ),
        ]),
      ),
    ));
  }
  void setIpv6Address() async{
    Map<String, String> headers = {
      'Authorization': 'Bearer 2PJqDIbR1I76Jb3BijggUe0HJEy_41HZk6aT2WsJzt395DdSV',
      'ngrok-version': '2'
    };
    String ngrokUrl;
    var response = await http.get(Uri.parse(AppValues.getNgrokApiUrl()), headers: headers);
    if (response.statusCode == 200) {
      ngrokUrl = jsonDecode(response.body)['tunnels'][0]['public_url'];
      debugPrint("ngrokUrl: $ngrokUrl");
    } else {
      throw Exception('Failed to fetch ipv6 address');
    }

    final ipv6Response = await http.get(Uri.parse("$ngrokUrl/alexa-voice-monkey/getIpv6Address"));
    if (response.statusCode == 200) {
      debugPrint("Ipv6 Address: ${ipv6Response.body}");
      AppValues.ipv6Address = ipv6Response.body;
    } else {
      throw Exception('Failed to fetch ipv6 address');
    }

  }
}
