// ignore_for_file: unnecessary_const

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'assets/constants.dart' as constants;

class ManagePhotos extends StatefulWidget {
  const ManagePhotos({super.key});

  @override
  State<ManagePhotos> createState() => _ManagePhotosState();
}

List<Container> textArrayElement = [];
List<String> textArray = [];

class _ManagePhotosState extends State<ManagePhotos> {
  late String noteEntered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 1,
            ),
            const Divider(
              color: Colors.black,
            ),
            Image.network(
                fit: BoxFit.cover,
                height: 300.0,
                width: double.infinity,
                'http://[2405:201:c018:400b:41d3:b8f9:2ed5:9089]:7000/photos/3'),
            Row(
              children: [
                const SizedBox(
                  height: 1,
                ),
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
          ],
        ),
      ),
    );
  }
}
