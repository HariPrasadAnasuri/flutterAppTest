// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'assets/constants.dart' as constants;

class AlexaVoiceSays extends StatefulWidget {
  const AlexaVoiceSays({super.key});

  @override
  State<AlexaVoiceSays> createState() => _AlexaVoiceSays();
}

List<String> list = <String>['Ha ha ha ha ha', 'Nice', 'Hmmm', 'Better'];

class _AlexaVoiceSays extends State<AlexaVoiceSays> {
  late String sayEntered;
  late String dropdownValue = list.first;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  sayEntered = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint("Adding note");
                setState(() {
                  debugPrint(sayEntered);
                  list.add(sayEntered);
                });
              },
              child: const Text('Add say'),
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) async {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                  debugPrint("sayEntered: $dropdownValue");
                });
                var url =
                    Uri.parse("${constants.hallAnnouncement}$dropdownValue");
                debugPrint("URL $url");
                await http.get(url);
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
