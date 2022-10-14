import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/alexa_voice_says.dart';
import 'package:flutter_application_1/harsha_task.dart';
import 'package:flutter_application_1/learn_flutter_page.dart';
import 'package:flutter_application_1/manage_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String textEntered = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: Column(children: [
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {
            if (textEntered.isNotEmpty) {
              AppValues.myName = textEntered;
              var url = Uri.parse(AppValues.getCurrentIndexUrl());
              var result = await http.get(url);
              var response = jsonDecode(result.body);
              AppValues.index = response["fileIndex"];
              debugPrint("Index retrieved from API: ${AppValues.index}");

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
        TextField(
          onChanged: (value) async {
            textEntered = value;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Your name',
          ),
        ),
      ])),
    ));
  }
}
