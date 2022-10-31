import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/alexa_voice_says.dart';
import 'package:flutter_application_1/harsha_task.dart';
import 'package:flutter_application_1/learn_flutter_page.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/manage_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _HomePageState extends State<HomePage> {
  String textEntered = "";
  late String dropdownValue = list.first;
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
          const SizedBox(height: 12),
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
          ),
          const SizedBox(height: 12),
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
          ),
          const SizedBox(height: 12),
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
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              if (textEntered.isNotEmpty) {
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
          ),
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
        ]),
      ),
    ));
  }
}
