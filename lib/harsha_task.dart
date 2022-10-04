// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'assets/constants.dart' as constants;

class HarshaTask extends StatefulWidget {
  const HarshaTask({super.key});

  @override
  State<HarshaTask> createState() => _HarshaTaskState();
}

List<Container> textArrayElement = [];
List<String> textArray = [];

class _HarshaTaskState extends State<HarshaTask> {
  late String noteEntered;

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
            Image.asset('images/combinedHarsha.jpg'),
            const SizedBox(
              height: 1,
            ),
            const Divider(
              color: Colors.black,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  noteEntered = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    debugPrint("Adding note");
                    setState(() {
                      textArray.add(noteEntered);
                      textArrayElement.add(Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        color: Colors.blueGrey,
                        child: Center(
                          child: Text(noteEntered,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ));
                    });
                  },
                  child: const Text('Add game action'),
                ),
                const SizedBox(
                  width: 2,
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("Remove last note");
                    setState(() {
                      if (textArrayElement.isNotEmpty) {
                        textArrayElement.removeLast();
                        textArray.removeLast();
                      }
                    });
                  },
                  child: const Text('Undo'),
                ),
                const SizedBox(
                  width: 2,
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("Clear all");
                    setState(() {
                      if (textArrayElement.isNotEmpty) {
                        textArrayElement.clear();
                        textArray.clear();
                      }
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: textArrayElement,
            ),
            ElevatedButton(
              onPressed: () async {
                String questData = textArray.join(",");
                var url = Uri.parse(
                    "${constants.raspberryAppUrl}/addQuestData?questDataString=$questData");
                // var url = Uri.parse(
                //     "http://10.0.2.2:8071/addQuestData?questDataString=$questData - delete");
                debugPrint("URL $url");
                await http.get(url);
                debugPrint("Submit task $questData");
              },
              child: const Text('Submit task'),
            ),
          ],
        ),
      ),
    );
  }
}
